# frozen_string_literal: true

require 'tempfile'

require 'eksek'
require 'eksekuter'

RSpec.describe 'Eksekuter#run.success?' do
  it 'returns true or false' do
    expect(Eksekuter.new('true').run.success?).to be(true)
    expect(Eksekuter.new('exit 1').run.success?).to be(false)
  end
end

RSpec.describe 'Eksekuter#run.success! and #eksek!' do
  it 'fails on Eksekuter#success! and :eksek! when appropriatly' do
    expect { Eksekuter.new('true').run.success! }.not_to raise_error
    expect { Eksekuter.new('exit 1').run.success! }.to raise_error EksekError

    expect { eksek! 'true' }.not_to raise_error
    expect { eksek! 'exit 1' }.to raise_error EksekError
  end
end

RSpec.describe 'Eksekuter#run.exit_code' do
  it 'returns the exit code' do
    expect(Eksekuter.new('exit 0').run.exit_code).to be(0)
    expect(Eksekuter.new('exit 1').run.exit_code).to be(1)
    expect(Eksekuter.new('exit 7').run.exit_code).to be(7)
  end
end

RSpec.describe 'Eksekuter#run.stdout, Eksekuter#run.stderr' do
  it 'captures the stdout and stderr separately' do
    expect(eksek('echo Hello').stdout).to eq('Hello')
    expect(eksek('echo Hello >&2').stderr).to eq('Hello')
  end
end

RSpec.describe 'Eksekuter#run.success! chaining' do
  it 'lets you combine EksekResult#run.success! and stdout/stderr/exit_code' do
    expect(Eksekuter.new('echo Hello').run.success!.stdout).to eq('Hello')
    expect(Eksekuter.new('echo Hello >&2').run.success!.stderr).to eq('Hello')
    expect(Eksekuter.new('exit 0').run.success!.exit_code).to be(0)
    expect { Eksekuter.new('exit 1').run.success!.stdout }
      .to raise_error EksekError
  end
end

RSpec.describe 'Standard input' do
  it 'accepts a block where the stdin can be written to' do
    result = Eksekuter.new('read A B; echo $A, $B')
                      .run { |i| i.write('Hi world') }
    expect(result.stdout).to eq('Hi, world')

    result = eksek('read A B; echo $A, $B') { |i| i.write('Hi world') }
    expect(result.stdout).to eq('Hi, world')
  end

  it 'reads a String that the block returns' do
    result = Eksekuter.new('read A; echo $A').run { 'Hello' }
    expect(result.stdout).to eq('Hello')
  end

  it 'reads an IO that the block returns' do
    file = Tempfile.open
    file.write('Hello')
    file.close

    File.open(file.path) do |f|
      result = Eksekuter.new('read A; echo $A!!!').run { f }
      expect(result.stdout).to eq('Hello!!!')
    end

    file.unlink
  end
end

RSpec.describe 'Kernel#spawn-style parameters' do
  it 'accepts a Hash as an optional first parameter' do
    result = Eksekuter.new({ 'TEXT' => 'Hello' }, 'echo $TEXT').run
    expect(result.stdout).to eq('Hello')

    result = eksek({ 'TEXT' => 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'stringifies the keys of the environment' do
    result = Eksekuter.new({ TEXT: 'Hello' }, 'echo $TEXT').run
    expect(result.stdout).to eq('Hello')

    result = eksek({ TEXT: 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'accepts a variable-length parameter list as command' do
    result = Eksekuter.new('echo', 'Hello', 'World').run
    expect(result.stdout).to eq('Hello World')

    result = eksek 'echo', 'Hello', 'World'
    expect(result.stdout).to eq('Hello World')
  end
end

RSpec.describe 'EksekResult#to_s' do
  it 'returns the stdout' do
    command = 'echo HelloStdout && echo HelloStderr >&2'
    output = "The output was: #{Eksekuter.new(command).run}."
    expect(output).to eq('The output was: HelloStdout.')
  end
end
