require 'contextual_logging'
describe ContextualLogging::Logger do
  before(:each) do
    ContextualLogging::Logger.reset_thread_context!
  end

  let(:log_stream)  { StringIO.new }
  let(:underlogger) { ::Logger.new(log_stream) }
  let(:logger)      { ContextualLogging::Logger.new(underlogger) }

  describe "#current_context" do
    it 'should return a RequestContext for the current thread' do
      expect(logger.current_context).to be_a(HashWithIndifferentAccess)
      expect(logger.current_context).to eql(Thread.current[ContextualLogging::Logger::LOGGER_CONTEXT_THREAD_VAR_KEY])
    end
  end

  describe "#add_context" do
    it 'should add to current_context' do
      logger.add_context test_context_please_ignore: true
      expect(logger.current_context).to eql('test_context_please_ignore' => true)
    end
  end

  describe "#with_context" do
    it 'should mix in some context for the length of the block' do
      starting_context = logger.current_context.dup
      inner_context = inner_inner_context = nil

      inner_ctx_sample   = {extra_test_context: 'just some text', maybe_an_array: [:a, :b, :c]}
      inner_inner_sample = {more_inner: 'zomg nested'}

      logger.with_context(inner_ctx_sample) do
        inner_context = logger.current_context.dup

        logger.with_context(inner_inner_sample) do
          inner_inner_context = logger.current_context.dup
        end
      end

      expect(starting_context).to be_a(HashWithIndifferentAccess)
      expect(logger.current_context).to eql(starting_context)
      expect(inner_context).to eql(HashWithIndifferentAccess.new(inner_ctx_sample))
      expect(inner_inner_context).to eql(HashWithIndifferentAccess.new(inner_ctx_sample.merge(inner_inner_sample)))
    end
  end

  describe '#clear_context!' do
    it 'should clear the context by removing the currently set instance' do
      logger.add_context john_something: true
      old_context = logger.current_context.dup
      logger.clear_context!
      expect(logger.current_context).to eql(HashWithIndifferentAccess.new)
      expect(logger.current_context).to_not eql(old_context)
    end
  end

  describe "#add" do
    %w( fatal error warn info debug unknown ).each do |log_level|
      it "should be called by ##{log_level}" do
        log_msg = "Just thought you should know. I'm logging: #{log_level}"
        expect(logger).to receive(:add).with(eval("Logger::#{log_level.upcase}"), nil, log_msg)
        logger.send(log_level, log_msg)
      end
    end

    it "should publish a logstash event to the log stream" do
      log_msg = "Some information all on its own"
      logger.add_context test_context_please_ignore: true, someother_request_context: 'this is awesome request 123123'

      stub_time = Time.at(1408145453)
      allow(Time).to receive(:now) { stub_time }
      logger.info(log_msg)
      log_stream.rewind
      logged = log_stream.read
      expected = {
        "test_context_please_ignore"=>true,
        "someother_request_context"=>"this is awesome request 123123",
        "message"=>"Some information all on its own",
        "log_level"=>"INFO",
        "@timestamp"=>stub_time.iso8601(3),
        "@version"=>"1"
      }
      hash = JSON[logged]
      expect(hash).to eql(expected)
    end
  end
end

