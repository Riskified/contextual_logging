# ContextualLogging

## Usage
Intended use is to wrap an underlying log device which corresponds to the logging subsystem in the given
environment. For example, development.rb might have something like this:
```
config.logger = ContextualLogging::Logger.new(::Logger.new(STDOUT))
```
or for use in production. Something like this for production.rb

```
logstash_socket = UDPSocket.new.tap {|s| s.connect(Settings.logstash.host, Settings.logstash.udp_port) }
config.logger = ContextualLogging::Logger.new(::Logger.new(logstash_socket))
```

This project rocks and uses MIT-LICENSE.
