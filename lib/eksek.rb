# frozen_string_literal: true

require 'open3'

require_relative 'eksek_error'
require_relative 'eksekuter'

# Executes shell commands and can be specified to return the standard output,
# standard error, etc.
# Accepts the same options as Process.spawn e.g. :chdir, :env.
class Eksek
  ALLOWED_METHODS = %i[
    exit stdout stderr stdouterr success? success!
  ].freeze

  class << self
    def respond_to_missing? name, include_private
      method_name_valid?(name) || super
    end

    def method_missing symbol, *args, &block
      return super unless method_name_valid? symbol
      methods = symbol.to_s.split('_').map(&:to_sym)
      cmd, opts = validate_args(args)
      Eksekuter.new(methods, cmd, opts).run(&block)
    end

    def method_name_valid? name
      methods = name.to_s.split('_').map(&:to_sym)
      methods.all? { |m| ALLOWED_METHODS.include? m }
    end

    def validate_conflicting_methods methods
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
    def validate_args args
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
