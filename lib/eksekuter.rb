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

  def run *args, **opts, &block
    env, cmd = separate_env_and_cmd(args)
    # p opts
    capture = opts.delete(:capture) || false
    streams = get_out_err_streams(capture)

    set_streams_in_opts streams, opts

    params = { env: env, cmd: cmd, opts: opts, block: block }

    process_status = run_process(params, streams)
    assemble_result(params, process_status, streams)
  end

  private

  def separate_env_and_cmd args
    env = args[0].is_a?(Hash) ? args.shift : {}
    env = env.each_with_object({}) { |(k, v), o| o[k.to_s] = v }
    cmd = args.size == 1 ? args.first : args
    [env, cmd]
  end

  def get_out_err_streams capture
    if capture
      out_readable, out_writable = IO.pipe
      err_readable, err_writable = IO.pipe
      return {
        out: {readable: out_readable, writable: out_writable},
        err: {readable: err_readable, writable: err_writable}
      }
    end

    {
      out: {readable: nil, writable: STDOUT},
      err: {readable: nil, writable: STDERR}
    }
  end

  def set_streams_in_opts streams, opts
    opts[:out] = streams.fetch(:out).fetch(:writable) unless opts[:out]
    opts[:err] = streams.fetch(:err).fetch(:writable) unless opts[:err]
  end

  def run_process params, streams
    pid = spawn(params.fetch(:env), *params.fetch(:cmd), params.fetch(:opts))
    close_streams streams
    _, process_status = Process.wait2(pid)
    process_status
  end

  def close_streams streams
    out_writable = streams.fetch(:out).fetch(:writable)
    err_writable = streams.fetch(:err).fetch(:writable)
    out_writable&.close if out_writable != STDOUT
    err_writable&.close if err_writable != STDERR
  end

  def assemble_result params, process_status, streams
    EksekResult.new(
      params.fetch(:env),
      params.fetch(:cmd),
      process_status.exitstatus,
      streams.fetch(:out).fetch(:readable),
      streams.fetch(:err).fetch(:readable)
    )
  end
end
