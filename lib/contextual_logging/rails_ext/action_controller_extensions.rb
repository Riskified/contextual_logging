module ContextualLogging
  module ActionControllerExtensions
    extend ActiveSupport::Concern

    def process_action(*args)
      setup_log_context
      super
    end

    private
    def setup_log_context
      ctx_payload = {
        :controller => self.class.name,
        :action     => self.action_name,
        :params     => request.filtered_parameters,
      }
      Rails.logger.add_context(ctx_payload) if Rails.logger.respond_to?(:add_context)
    end
  end
end
