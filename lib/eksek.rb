# frozen_string_literal: true

require 'open3'

class EksekError < StandardError
end

# Executes she ll commands and can be specified to return the standard output,
# standard error, etc.
# Accepts the same options as Process.spawn e.g. :chdir, :env.
class Eksek
  ALLOWED_METHODS = %i[
    exit stdout stderr stdouterr success? success!
  ].freeze

  class << self
    def respond_to_missing?(name, include_private)
      return true if method_name_valid? name
      super name, include_private
    end

    def method_missing(symbol, *args)
      return super symbol, args unless method_name_valid? symbol
      methods = symbol.to_s.split('_').map(&:to_sym)
      cmd, opts = validate_args(args)
      stdin, stdout, stderr, stdouterr, wait_thr = spawn(cmd, opts)
      read_block_into_stdin((yield stdin), stdin) if block_given?
      stdin.close
      process_status = wait_thr.value
      outs = [stdout, stderr, stdouterr].map do |stream|
        result = stream.read.chomp
        stream.close
        result
      end
      assemble_result cmd, methods, outs[0], outs[1], outs[2], process_status
    end

    def read_block_into_stdin(block_result, stdin)
      return if stdin.closed?
      if block_result.is_a? String
        stdin.write block_result
        return nil
      end
      if block_result.respond_to? :read
        IO.copy_stream(block_result, stdin)
        return nil
      end
      nil
    end

    # @return stdin, stdout, stderr, stdouterr, wait_thr with nil for
    # stdout/stderr/stdouterr depending on which should be defined and which
    # not.
    def spawn(cmd, opts)
      stdout = stderr = stdouterr = nil
      if methods.include? :stdouterr
        stdin, stdouterr, wait = Open3.popen2e(cmd, opts)
      else
        stdin, stdout, stderr, wait = Open3.popen3(cmd, opts)
      end
      [
        stdin,
        stdout ? stdout : dummy_stream,
        stderr ? stderr : dummy_stream,
        stdouterr ? stdouterr : dummy_stream,
        wait,
      ]
    end

    def dummy_stream
      StringIO.new('', 'r')
    end

    def assemble_result(cmd, methods, stdout, stderr, stdouterr, process_status)
      fails = methods.include?(:success!) && !process_status.success?
      raise EksekError, "Command failed: #{cmd.inspect}" if fails
      method_to_result = {
        stdout: stdout,
        stderr: stderr,
        stdouterr: stdouterr,
        success?: process_status.success?,
        exit: process_status.exitstatus,
      }
      result = methods.map { |method| method_to_result[method] }
      return result.first if result.length == 1
      result
    end

    def method_name_valid?(name)
      methods = name.to_s.split('_').map(&:to_sym)
      methods.all? { |m| ALLOWED_METHODS.include? m }
    end

    def validate_conflicting_methods(methods)
      methods_are_conflicting =
        if methods.include? :stdouterr
          methods.include?(:stderr) || methods.include?(:stdout)
        else
          true
        end
      error_message = 'Cannot call stdouterr with either stdout or stderr'
      raise EksekError, error_message if methods_are_conflicting
    end

    # @return an array of a String and a Hash, representing the command and the
    # opts
    def validate_args(args)
      raise EksekError, 'Must provide at least a command' if args.empty?

      cmd = args[0]
      raise TypeError, 'Command must be a string' unless cmd.is_a? String
      expected_hash_message = 'Expected argument 2 to be a Hash'
      has_invalid_opts = args.length > 1 && !args[1].is_a?(Hash)
      raise TypeError, expected_hash_message if has_invalid_opts
      opts = args[1] || {}
      [cmd, opts]
    end
  end
end
