module ContextualLogging
  class Railtie < ::Rails::Railtie
    config.contextual_logging = ActiveSupport::OrderedOptions.new

    initializer "contextual_logging.initialize" do
      ActiveSupport.on_load(:action_controller) do
        include ContextualLogging::ActionControllerExtensions
      end
    end

    initializer "contextual_logging.swap_logging_middleware" do |app|
      app.config.middleware.swap Rails::Rack::Logger, ContextualLogging::Rack::Logger, app.config.log_tags, app.config.contextual_logging.context_from_request
    end
  end
end

