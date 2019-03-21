# frozen_string_literal: true

require 'eksek'
require 'eksekuter'

RSpec.describe 'Eksekuter success methods' do
  it 'returns true or false depending on the exit code' do
    expect(Eksekuter.new.run('true').success?).to be(true)
    expect(Eksekuter.new.run('exit 1').success?).to be(false)
  end

  it 'fails when appropriate' do
    expect { Eksekuter.new.run('true').success! }.not_to raise_error
    expect { Eksekuter.new.run('exit 1').success! }.to raise_error EksekError
  end

  it 'returns the exit code' do
    expect(Eksekuter.new.run('exit 0').exit_code).to be(0)
    expect(Eksekuter.new.run('exit 1').exit_code).to be(1)
    expect(Eksekuter.new.run('exit 7').exit_code).to be(7)
  end
end

RSpec.describe 'Eksekuter capturing options' do
  it 'captures the stdout and stderr separately' do
    expect(Eksekuter.new.run('printf Hello', capture: true).stdout)
      .to eq('Hello')
    expect(Eksekuter.new.run('printf Hello >&2', capture: true).stderr)
      .to eq('Hello')
  end

  it 'outputs to stdout/stderr when disabling I/O capturing' do
    expect { Eksekuter.new.run('printf Hello', capture: false) }
      .to output('Hello').to_stdout_from_any_process
    expect { Eksekuter.new.run('printf Hello >&2', capture: false) }
      .to output('Hello').to_stderr_from_any_process
  end
end

RSpec.describe 'Standard input' do
  it 'can write to a custom IO object' do
    readable, writable = IO.pipe
    Eksekuter.new.run('printf Hello', out: writable)
    writable.close
    expect(readable.read).to eq('Hello')
  end

  it 'can read from a custom IO object' do
    readable, writable = IO.pipe
    writable.write 'Hello'
    writable.close
    result = Eksekuter.new.run('read A; printf $A', in: readable, capture: true)
    expect(result.stdout).to eq('Hello')
  end
end

RSpec.describe 'Kernel#spawn-style parameters' do
  it 'accepts a Hash as an optional first parameter' do
    result = Eksekuter.new
      .run({ 'TEXT' => 'Hello' }, 'printf $TEXT', capture: true)
    expect(result.stdout).to eq('Hello')
  end

  it 'stringifies the keys of the environment' do
    result = Eksekuter.new
      .run({ TEXT: 'Hello' }, 'printf $TEXT', capture: true)
    expect(result.stdout).to eq('Hello')
  end

  it 'accepts a variable-length parameter list as command' do
    result = Eksekuter.new
      .run('echo', 'Hello', 'World', capture: true)
    expect(result.stdout).to eq("Hello World\n")
  end
end
