module ContextualLogging
  class DelayedJob < Delayed::Plugin

    callbacks do |lifecycle|
      lifecycle.around(:execute) do |worker, *args, &block|
        Rails.logger.clear_context!
        Rails.logger.add_context("omri_1_#{rand(10)}" => 'Hello')
        block.call(worker, *args)
      end

      lifecycle.around(:invoke_job) do |job, *args, &block|
        Rails.logger.add_context("omri_2_#{rand(10)}" => 'Hello')
        block.call(job, *args)
      end
    end


  end
end

Delayed::Worker.plugins << ContextualLogging::DelayedJob