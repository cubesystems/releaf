require "timeout"

module WaitSteps
  extend RSpec::Matchers::DSL

  matcher :become_true do
    match do |block|
      begin
        Timeout.timeout(Capybara.default_max_wait_time) do
          sleep(0.1) until value = block.call
          sleep(0.2)
          value
        end
      rescue TimeoutError
        false
      end
    end

    def supports_block_expectations?
      true
    end
  end
end
