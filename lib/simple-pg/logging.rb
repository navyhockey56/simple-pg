require 'logger'

module SimplePG
  def self.log=(logger)
    raise 'Invalid logger' unless [:info, :error, :debug].all? { |type| logger.respond_to? type }

    @log = logger
  end

  def self.log
    @log ||= Logger.new(STDOUT);
  end

  def self.log_error(e, verbose: false)
    msg = "An error occurred: #{e.class} - #{e.message}\n#{e.backtrace.join("\n\t")}"
    verbose ? self.verbose_log(msg, level: :error) : self.log.error(msg)
  end

  # Allows for logging of messages only when environment variable `VERBOSE`
  # is set to true.
  #
  # @param [String] msg - The message to log
  # @param [Symbol] :level (Default = `:info`) - The logging level to log at
  def self.verbose_log(msg, level: :info)
    return unless (@@verbose_log ||= ENV['VERBOSE'].to_s.casecmp('true').zero?)

    case(level.to_sym)
    when :info
      self.log.info msg
    when :debug
      self.log.debug msg
    when :error
      self.log.error msg
    end
  end
end
