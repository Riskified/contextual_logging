require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/object/blank'
require 'active_support/log_subscriber'

module ContextualLogging
  module Rack
    # Sets log tags, logs the request, calls the app, and flushes the logs.
    class Logger < ActiveSupport::LogSubscriber
      def initialize(app, taggers = nil, context_mixers = nil)
        @app, @taggers = app, taggers || []
        @context_mixers = context_mixers
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        if Rails.logger.respond_to?(:with_context)
          Rails.logger.with_context(compute_context(request)) { call_app(request, env) }
        elsif Rails.logger.respond_to?(:tagged)
          Rails.logger.tagged(compute_tags(request)) { call_app(request, env) }
        else
          call_app(request, env)
        end
      end

      protected

      def call_app(request, env)
        Rails.logger.info started_request_message(request)
        @app.call(env)
      ensure
        ActiveSupport::LogSubscriber.flush_all!
      end

      # Started GET "/session/new" for 127.0.0.1 at 2012-09-26 14:51:42 -0700
      def started_request_message(request)
        'Started %s "%s" for %s at %s' % [
          request.request_method,
          request.filtered_path,
          request.ip,
          Time.now.to_default_s ]
      end

      def compute_tags(request)
        @taggers.collect do |tag|
          case tag
          when Proc
            tag.call(request)
          when Symbol
            request.send(tag)
          else
            tag
          end
        end
      end

      def compute_context(request)

        starting_context = {
          request_uuid: request.uuid,
          request_method: request.request_method,
          request_remote_ip: request.ip,
          request_path: request.filtered_path,
          request_subdomain: request.subdomain,
          # TODO: Get the mime type of the request without clobbering the action/controller params
          #request_format: request.format.try(:ref),
          tags: compute_tags(request).reject(&:blank?)
        }
        custom_mixed_in = @context_mixers && @context_mixers.call(request)

        if custom_mixed_in
          starting_context.merge(custom_mixed_in)
        else
          starting_context
        end
      end
    end
  end
end
