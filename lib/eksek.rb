# frozen_string_literal: true

require_relative 'eksekuter'

# Executes shell commands and can be specified to return the standard output,
# standard error, etc.
# Accepts the same options as Process.spawn e.g. :chdir, :env.
module Kernel
  private

  def eksek *args, **opts, &block
    Eksekuter.new.exec(*args, **opts, &block)
  end

  def eksek! *args, **opts, &block
    eksek(*args, **opts, &block).success!
  end

  def kapture *args, **opts, &block
    Eksekuter.new.capture(*args, **opts, &block)
  end

  def kapture! *args, **opts, &block
    kapture(*args, **opts, &block).success!
  end
end
