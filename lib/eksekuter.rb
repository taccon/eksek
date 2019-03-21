# frozen_string_literal: true

require 'open3'

require_relative 'eksek_result'

# Class that command execution is delegated to by Eksek.
class Eksekuter
  # @param {Logger} logger
  def initialize logger: nil
    @logger = logger
    @stdout_buffer = nil
    @stderr_buffer = nil
    @stdin_buffer = nil
  end

  # Wraps around Kernel#spawn so that the return value is an EksekResult.
  # @return EksekResult
  def exec *args, **opts
    env, cmd = split_env_and_cmd(args)
    params = { env: env, cmd: cmd, opts: opts }
    process_status = spawn_and_get_status(params)
    assemble_result(params, process_status)
  end

  # Like Eksekuter#exec but the :out and :err options are ignored; instead
  # the output is attached to the EksekResult object returned.
  # Returns an EksekResult object which getters :stdout and :stderr containing
  # the corresponding output of the spawned process.
  # @return EksekResult
  def capture *args, **opts
    env, cmd = split_env_and_cmd(args)
    out_read, out_write = IO.pipe
    err_read, err_write = IO.pipe
    opts2 = opts.merge(out: out_write, err: err_write)
    params = { env: env, cmd: cmd, opts: opts2 }
    process_status = spawn_and_get_status(params)
    out_write.close
    err_write.close
    assemble_result(params, process_status, out_read, err_read)
  end

  private

  def split_env_and_cmd args
    cmd_args = args.clone
    env = cmd_args.first.is_a?(Hash) ? cmd_args.shift : {}
    env = env.each_with_object({}) { |(k, v), o| o[k.to_s] = v }
    cmd = cmd_args.size == 1 ? cmd_args.first : cmd_args
    [env, cmd]
  end

  def spawn_and_get_status params
    env = params.fetch(:env)
    cmd = params.fetch(:cmd)
    opts = params.fetch(:opts)
    pid = spawn(env, *cmd, opts)
    _, process_status = Process.wait2(pid)
    process_status
  end

  def assemble_result params, process_status, out_stream = nil, err_stream = nil
    EksekResult.new(
      params.fetch(:env),
      params.fetch(:cmd),
      process_status.exitstatus,
      out_stream,
      err_stream,
    )
  end
end
