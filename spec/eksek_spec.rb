# frozen_string_literal: true

require 'tempfile'

require 'eksek'
require 'eksekuter'

RSpec.describe 'Eksekuter#run.success?' do
  it 'returns true or false' do
    expect(Eksekuter.new.run('true').success?).to be(true)
    expect(Eksekuter.new.run('exit 1').success?).to be(false)
  end
end

RSpec.describe 'Eksekuter#run.success! and #eksek!' do
  it 'fails on Eksekuter#success! and :eksek! when appropriatly' do
    expect { Eksekuter.new.run('true').success! }.not_to raise_error
    expect { Eksekuter.new.run('exit 1').success! }.to raise_error EksekError

    expect { eksek! 'true' }.not_to raise_error
    expect { eksek! 'exit 1' }.to raise_error EksekError
  end
end

RSpec.describe 'Eksekuter#run.exit_code' do
  it 'returns the exit code' do
    expect(Eksekuter.new.run('exit 0').exit_code).to be(0)
    expect(Eksekuter.new.run('exit 1').exit_code).to be(1)
    expect(Eksekuter.new.run('exit 7').exit_code).to be(7)
  end
end

RSpec.describe 'Eksekuter#run.stdout, Eksekuter#run.stderr' do
  it 'captures the stdout and stderr separately' do
    expect(Eksekuter.new.run('echo Hello').stdout).to eq('Hello')
    expect(Eksekuter.new.run('echo Hello >&2').stderr).to eq('Hello')
  end
end

RSpec.describe 'Eksekuter#run.success! chaining' do
  it 'lets you combine EksekResult#run.success! and stdout/stderr/exit_code' do
    expect(Eksekuter.new.run('echo Hello').success!.stdout).to eq('Hello')
    expect(Eksekuter.new.run('echo Hello >&2').success!.stderr).to eq('Hello')
    expect(Eksekuter.new.run('exit 0').success!.exit_code).to be(0)
    expect { Eksekuter.new.run('exit 1').success!.stdout }
      .to raise_error EksekError
  end
end

RSpec.describe 'Standard input' do
  it 'accepts a block where the stdin can be written to' do
    result = Eksekuter.new.run('read A B; echo $A, $B') do |i|
      i.write('Hi world')
    end
    expect(result.stdout).to eq('Hi, world')

    result = eksek('read A B; echo $A, $B') do |i|
      i.write('Hi world')
    end
    expect(result.stdout).to eq('Hi, world')
  end

  it 'reads a String that the block returns' do
    result = Eksekuter.new.run('read A; echo $A') { 'Hello' }
    expect(result.stdout).to eq('Hello')
  end

  it 'reads an IO that the block returns' do
    file = Tempfile.open
    file.write('Hello')
    file.close

    File.open(file.path) do |f|
      result = Eksekuter.new.run('read A; echo $A!!!') { f }
      expect(result.stdout).to eq('Hello!!!')
    end

    file.unlink
  end
end

RSpec.describe 'Kernel#spawn-style parameters' do
  it 'accepts a Hash as an optional first parameter' do
    result = Eksekuter.new.run({ 'TEXT' => 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')

    result = eksek({ 'TEXT' => 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'stringifies the keys of the environment' do
    result = Eksekuter.new.run({ TEXT: 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')

    result = eksek({ TEXT: 'Hello' }, 'echo $TEXT')
    expect(result.stdout).to eq('Hello')
  end

  it 'accepts a variable-length parameter list as command' do
    result = Eksekuter.new.run('echo', 'Hello', 'World')
    expect(result.stdout).to eq('Hello World')

    result = eksek('echo', 'Hello', 'World')
    expect(result.stdout).to eq('Hello World')
  end
end
