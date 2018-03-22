# frozen_string_literal: true

require_relative 'eksekuter'

# Executes shell commands and can be specified to return the standard output,
# standard error, etc.
# Accepts the same options as Process.spawn e.g. :chdir, :env.
module Kernel
  private

  def eksek cmd, opts = {}, &block
    Eksekuter.new(cmd, opts).run(&block)
  end

  def eksek! cmd, opts = {}, &block
    eksek(cmd, opts, &block).success!
  end
end
