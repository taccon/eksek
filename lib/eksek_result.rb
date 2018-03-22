# frozen_string_literal: true

require_relative 'eksek_error'

# Describes a result object to be used for evaluating
# return values from a command
class EksekResult
  def initialize cmd, exit_code, success, stdout, stderr
    @cmd = cmd
    @exit_code = exit_code
    @success = success
    @stdout = stdout
    @stderr = stderr
  end

  attr_reader :exit_code, :stdout, :stderr

  def success?
    @success
  end

  def success!
    raise EksekError, "Command failed: #{@cmd.inspect}" unless success?
    self
  end
end
