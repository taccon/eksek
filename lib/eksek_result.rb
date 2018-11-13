# frozen_string_literal: true

require_relative 'eksek_error'

# Describes a result object to be used for evaluating
# return values from a command
class EksekResult
  def initialize env, cmd, exit_code, out_stream, err_stream
    @env = env
    @cmd = cmd
    @exit_code = exit_code
    @out_stream = out_stream
    @err_stream = err_stream
  end
  # rubocop:enable Metrics/ParameterLists

  attr_reader :exit_code

  def stdout
    @stdout ||= @out_stream&.read
  end

  def stderr
    @stderr ||= @err_stream&.read
  end

  def success?
    @exit_code.zero?
  end

  def ?
    success?
  end

  def success!
    raise EksekError, "Command failed: #{@cmd.inspect}" unless success?
    self
  end

  def !
    success!
  end

  def to_s
    stdout
  end
end
