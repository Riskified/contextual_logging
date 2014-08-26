module ContextualLogging
  # Dependencies
  require 'active_support/core_ext/logger'
  require 'active_support/concern'
  require 'active_support/hash_with_indifferent_access'
  require 'logstash-event'

  # Supporting Files. We're not bothering with autoload.
  require 'contextual_logging/logger'
  require 'contextual_logging/logstash_formatter'
  require 'contextual_logging/rails_ext/action_controller_extensions'
  require 'contextual_logging/rack/logger'

  # Railtie
  require 'contextual_logging/railtie' if defined?(Rails)
end
