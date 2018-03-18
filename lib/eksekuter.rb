# frozen_string_literal: true

# Class that command execution is delegated to by Eksek.
class Eksekuter
  def initialize called_methods, cmd, opts
    @called_methods = called_methods.freeze
    @cmd = cmd
    @opts = opts.freeze
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
    :called_methods,
    :cmd,
    :err_str,
    :opts,
    :out_str,
    :outerr_str,
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

  def stdouterr
    @stdouterr ||= StringIO.new('', 'r')
  end

  def spawn_process
    @stdout = @stderr = @stdouterr = nil
    if called_methods.include? :stdouterr
      @stdin, @stdouterr, @wait_thr = Open3.popen2e(cmd, opts)
    else
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(cmd, opts)
    end
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
    streams = [stdout, stderr, stdouterr]
    @out_str, @err_str, @outerr_str = streams.map(&:read).map(&:chomp)
    streams.each(&:close)
    nil
  end

  def assemble_result
    raise EksekError, "Command failed: #{cmd.inspect}" if fails?
    result = called_methods.map { |method| method_to_result_mapping[method] }
    return result.first if result.length == 1
    result
  end

  def fails?
    @fails ||= called_methods.include?(:success!) && !process_status.success?
  end

  def method_to_result_mapping
    @method_to_result_mapping ||= {
      stdout: out_str,
      stderr: err_str,
      stdouterr: outerr_str,
      success?: process_status.success?,
      exit: process_status.exitstatus,
    }.freeze
  end
end
