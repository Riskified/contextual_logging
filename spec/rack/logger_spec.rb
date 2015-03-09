require 'spec_helper'

class MyController < ActionController::Base
  before_filter :grab_controller_stuff

  cattr_accessor :last_params
  def index
    Rails.logger.info("logging in the action: info")
    render :ok, :text => 'hey'
  end

  def grab_controller_stuff
    self.class.last_params = self.params
    true
  end

end

describe ContextualLogging::Rack::Logger do
  let(:logger_middleware) { ContextualLogging::Rack::Logger.new(app) }

  around(:each) do |example|
    @log_stream = StringIO.new
    @ctx_logger = ContextualLogging::Logger.new(::Logger.new(@log_stream))
    with_all_loggers_set_to(@ctx_logger) do
      example.run
    end
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end

  def with_all_loggers_set_to(logger)
    replacing_loggers_for = [Rails, ActionController::Base, ActiveRecord::Base]
    old_loggers = replacing_loggers_for.map { |s| s.send(:logger) }
    replacing_loggers_for.each {|s| s.send("logger=", logger) }
    yield
  ensure
    replacing_loggers_for.each_with_index {|s,i| s.send("logger=", old_loggers[i]) }
  end

  it "logs the initial request with added context" do
    req_id = SecureRandom.hex(16)
    env_with_req_id = env_for('/index', "REMOTE_ADDR" => '10.10.0.5', "action_dispatch.request_id" => req_id)
    app = ->(env) { [200, env, "app"] }
    request_path = nil
    some_taggers = [:uuid, ->(req) { request_path = req.path }]
    request_to_context = ->(req) {
      {extra_context: "extraaaa:#{req.uuid}"}
    }

    local_middleware = ContextualLogging::Rack::Logger.new(app, some_taggers, request_to_context)
    expect(ActiveSupport::LogSubscriber).to receive(:flush_all!)
    status, _env, _app = local_middleware.call env_with_req_id
    expect(status).to eql(200)
    log_lines = @log_stream.string.split("\n")
    expect(log_lines.size).to eql(1)
    parsed = JSON[log_lines.last]
    expect(parsed['request_uuid']).to eql(req_id)
    expect(parsed['message']).to match(%r{Started GET "/index" for 10\.10\.0\.5 at })
    expect(parsed['tags']).to eql([req_id, '/index'])
    expect(parsed['extra_context']).to eql("extraaaa:#{req_id}")
  end

  describe "called as part of the rails middleware" do
    before(:each) do
      app.routes.draw do
        get '/foo_index' => "my#index"
      end
    end

    it "should include context in the logger for the whole request" do
      get '/foo_index'
      log_lines = @log_stream.string.split("\n").map {|l| JSON[l]}
      expect(log_lines.map{|a| a['request_uuid']}.uniq.compact).to eql([log_lines[1]['request_uuid']])
      non_blank_keys = log_lines.map {|a| a.select{|k,v| v.presence }.keys }
      # Assert we cleared context
      expect(Rails.logger.current_context).to eql({})
    end

    it 'should not clobber action, controller from the params' do
      get '/foo_index'
      expect(MyController.last_params).to eql("controller" => "my", "action" => "index")
    end
  end
end
