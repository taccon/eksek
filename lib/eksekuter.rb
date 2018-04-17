# frozen_string_literal: true

require 'open3'

require_relative 'eksek_result'

# Class that command execution is delegated to by Eksek.
class Eksekuter
  # @param {Logger} logger
  def initialize logger: nil
    @logger = logger
  end

  def run *args, **opts, &block
    env, cmd = separate_env_and_cmd(args)
    params = { env: env, cmd: cmd, opts: opts, block: block }
    popen3_result = spawn_process(params)
    write_and_close_stdin(params, popen3_result)
    process_status = wait(popen3_result)
    out_str, err_str = read_and_close_stdout_stderr(popen3_result)
    assemble_result(params, process_status, out_str, err_str)
  end

  private

  def separate_env_and_cmd args
    env = args[0].is_a?(Hash) ? args.shift : {}
    env = env.each_with_object({}) { |(k, v), o| o[k.to_s] = v }
    cmd = args.size == 1 ? args.first : args
    [env, cmd]
  end

  def spawn_process params
    stdin, stdout, stderr, wait_thr = Open3.popen3(
      params.fetch(:env), *params.fetch(:cmd), params.fetch(:opts)
    )
    { stdin: stdin, stdout: stdout, stderr: stderr, wait_thr: wait_thr }
  end

  def write_and_close_stdin params, popen3_result
    stdin = popen3_result.fetch(:stdin)
    return if stdin.closed? || params.fetch(:block).nil?
    block_result = params.fetch(:block).call(stdin)
    block_result = StringIO.new(block_result) if block_result.is_a? String
    IO.copy_stream(block_result, stdin) if block_result.respond_to? :read
    stdin.close
    nil
  end

  def wait popen3_result
    popen3_result.fetch(:wait_thr).value # returns the process status
  end

  def read_and_close_stdout_stderr popen3_result
    streams = [popen3_result.fetch(:stdout), popen3_result.fetch(:stderr)]
    out_str, err_str = streams.map(&:read).map(&:chomp)
    streams.each(&:close)
    [out_str, err_str]
  end

  def assemble_result params, process_status, out_str, err_str
    EksekResult.new(
      params.fetch(:env),
      params.fetch(:cmd),
      process_status.exitstatus,
      process_status.success?,
      out_str,
      err_str,
    )
  end
end
