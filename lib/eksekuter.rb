# frozen_string_literal: true

require 'open3'

require_relative 'eksek_result'

# Class that command execution is delegated to by Eksek.
class Eksekuter
  def initialize *args, **opts
    @env = args[0].is_a?(Hash) ? args.shift : {}
    @env = @env.each_with_object({}) { |(k, v), o| o[k.to_s] = v }
    @cmd = args.size == 1 ? args.first : args
    @opts = opts
  end

  def run &block
    spawn_process
    write_and_close_stdin(&block)
    wait
    read_and_close_stdout_stderr
    assemble_result
  end

  private

  attr_reader(
    :cmd,
    :env,
    :err_str,
    :opts,
    :out_str,
    :process_status,
    :stdin,
    :wait_thr,
  )

  def stdout
    @stdout ||= StringIO.new('', 'r')
  end

  def stderr
    @stderr ||= StringIO.new('', 'r')
  end

  def spawn_process
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(env, *cmd, opts)
    nil
  end

  def write_and_close_stdin
    return if stdin.closed? || !block_given?
    block_result = yield stdin
    block_result = StringIO.new(block_result) if block_result.is_a? String
    IO.copy_stream(block_result, stdin) if block_result.respond_to? :read
    stdin.close
    nil
  end

  def wait
    @process_status = wait_thr.value
  end

  def read_and_close_stdout_stderr
    streams = [stdout, stderr]
    @out_str, @err_str = streams.map(&:read).map(&:chomp)
    streams.each(&:close)
    nil
  end

  def assemble_result
    EksekResult.new(
      env,
      cmd,
      process_status.exitstatus,
      process_status.success?,
      out_str,
      err_str,
    )
  end
end
