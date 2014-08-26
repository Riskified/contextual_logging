require 'spec_helper'

class MyController < ActionController::Base
  # Included here to test with, but in reality its included into ActionController::Base
  include ContextualLogging::ActionControllerExtensions

  def index
    Rails.logger.info("logging in the action: info")
    render :ok, :text => 'hey'
  end
end

describe MyController do
  around(:each) do |example|
    old_logger = Rails.logger
    @log_stream = StringIO.new
    Rails.logger = ContextualLogging::Logger.new(::Logger.new(@log_stream))
    begin
      example.run
    ensure
      Rails.logger = old_logger
    end
  end

  it "should mix in controller context before process action" do
    app.routes.draw do
      match '/index' => 'my#index'
    end
    get :index

    log_lines = @log_stream.string.split("\n").map { |e| JSON[e] }
    log_line = log_lines.last
    expected = {
      "controller"=>"MyController",
       "action"=>"index",
       "params"=>{},
       "message"=>"logging in the action: info",
       "request_format" => "html",
       "request_method" => "GET",
       "request_path" => '/index',
       "request_remote_ip" => "127.0.0.1",
       "request_subdomain" => '',
       "request_uuid" => '',
       "log_level"=>"INFO",
       "@timestamp"=>"2014-08-23T04:47:24Z",
       "@version"=>"1"
    }

    expect(log_line['controller']).to eql("MyController")
    expect(log_line['action']).to eql("index")
    expect(log_line['params']).to eql({})
  end
end

