# frozen_string_literal: true

require_relative 'eksek_error'

# Describes a result object to be used for evaluating
# return values from a command
class EksekResult
  # rubocop:disable Metrics/ParameterLists
  def initialize env, cmd, exit_code, success, stdout, stderr
    @env = env
    @cmd = cmd
    @exit_code = exit_code
    @success = success
    @stdout = stdout
    @stderr = stderr
  end
  # rubocop:enable Metrics/ParameterLists

  attr_reader :exit_code, :stdout, :stderr

  def success?
    @success
  end

  def success!
    raise EksekError, "Command failed: #{@cmd.inspect}" unless success?
    self
  end
end
