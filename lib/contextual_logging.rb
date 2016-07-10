module ContextualLogging
  # Dependencies
  require 'active_support/concern'
  require 'active_support/hash_with_indifferent_access'
  require 'logstash-event'

  # Supporting Files. We're not bothering with autoload.
  require 'contextual_logging/logger'
  require 'contextual_logging/logstash_message_formatter'
  require 'contextual_logging/rails_ext/action_controller_extensions'
  require 'contextual_logging/rack/logger'


  if defined?(Rails)
    # Railtie
    require 'contextual_logging/railtie'

    # Delayed Job
    require 'contextual_logging/delayed_job' if defined?(Delayed::Worker)
  end



end
