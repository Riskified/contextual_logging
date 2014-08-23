module ContextualLogging
  require 'active_support/core_ext/logger'
  require 'active_support/hash_with_indifferent_access'
  require 'logstash-event'
  require_relative 'contextual_logging/logger'
  require_relative 'contextual_logging/logstash_formatter'
end
