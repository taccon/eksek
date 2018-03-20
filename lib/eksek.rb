# frozen_string_literal: true

require 'open3'

require_relative 'eksek_error'
require_relative 'eksekuter'

# Executes shell commands and can be specified to return the standard output,
# standard error, etc.
# Accepts the same options as Process.spawn e.g. :chdir, :env.
class Eksek
  class << self
    def run cmd, opts = {}, &block
      verify cmd, opts

      Eksekuter.new(cmd, opts).run(&block)
    end

    alias ute run

    private

    def verify cmd, opts
      raise TypeError, 'Command must be a string' unless cmd.is_a? String
      expected_hash_message = 'Expected options to be a Hash'
      has_invalid_opts = !opts.is_a?(Hash)
      raise TypeError, expected_hash_message if has_invalid_opts
    end
  end
end
