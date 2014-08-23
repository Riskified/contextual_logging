module ContextualLogging
  # Very much inspired by ActiveSupport::TaggedLogging
  class Logger
    LOGGER_CONTEXT_THREAD_VAR_KEY = :__current_logstash_logger_context

    def initialize(logger, formatter = LogstashFormatter.new)
      @logger    = logger
      @formatter = formatter
    end

    def with_context(ctx)
      old_context = current_context.dup
      add_context(ctx)
      yield
    ensure
      set_context(old_context)
    end

    def add_context(ctx)
      current_context.merge!(ctx)
    end

    def clear_context!
      current_context.clear
    end

    # Inspired by super
    def add(severity, message = nil, progname = nil, &block)
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = nil
        end
      end

      formatted_message = @formatter.format(format_severity(severity), message, current_context)
      @logger.add(severity, formatted_message)
    end

    def current_context
      Thread.current[LOGGER_CONTEXT_THREAD_VAR_KEY] ||= HashWithIndifferentAccess.new
    end

    # Borrowed from TaggedLogging
    %w(fatal error warn info debug unknown).each do |severity|
      eval <<-EOM, nil, __FILE__, __LINE__ + 1
      def #{severity}(progname = nil, &block)
        add(::Logger::#{severity.upcase}, nil, progname, &block)
      end
      EOM
    end

    def flush
      clear_context!
      @logger.flush if @logger.respond_to?(:flush)
    end

    def method_missing(method, *args)
      @logger.send(method, *args)
    end

    if RUBY_VERSION < '1.9'
      def respond_to?(*args)
        super || @logger.respond_to?(*args)
      end
    else
      def respond_to_missing?(*args)
        @logger.respond_to?(*args)
      end
    end

    private

    def set_context(value)
      self.class.set_thread_context(value)
    end

    def self.reset_thread_context!
      set_thread_context(HashWithIndifferentAccess.new)
    end

    def self.set_thread_context(value)
      Thread.current[LOGGER_CONTEXT_THREAD_VAR_KEY] = value
    end
  end
end
