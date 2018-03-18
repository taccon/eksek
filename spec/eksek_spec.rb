# frozen_string_literal: true

require 'tempfile'

require 'eksek'

RSpec.describe Eksek, '#success?' do
  it 'returns true or false' do
    expect(Eksek.success?('true')).to be(true)
    expect(Eksek.success?('exit 1')).to be(false)
  end
end

RSpec.describe Eksek, '#success!' do
  it 'fails on :success! when appropriatly' do
    expect { Eksek.success!('true') }.not_to raise_error
    expect { Eksek.success!('exit 1') }.to raise_error EksekError
  end
end

RSpec.describe Eksek, '#exit' do
  it 'returns the exit code' do
    expect(Eksek.exit('exit 0')).to be(0)
    expect(Eksek.exit('exit 1')).to be(1)
    expect(Eksek.exit('exit 7')).to be(7)
  end
end

RSpec.describe Eksek, '#respond_to?' do
  it 'recognizes all basic methods' do
    expect(Eksek.respond_to?(:stdout)).to be(true)
    expect(Eksek.respond_to?(:stderr)).to be(true)
    expect(Eksek.respond_to?(:stdouterr)).to be(true)
    expect(Eksek.respond_to?(:exit)).to be(true)
    expect(Eksek.respond_to?(:success?)).to be(true)
    expect(Eksek.respond_to?(:success!)).to be(true)
  end

  it 'recognizes some combinations of methods' do
    expect(Eksek.respond_to?(:stdout_stderr_exit_success!)).to be(true)
    expect(Eksek.respond_to?(:stdout_stderr_exit_success?)).to be(true)
    expect(Eksek.respond_to?(:stdouterr_exit_success!)).to be(true)
    expect(Eksek.respond_to?(:stdouterr_exit_success?)).to be(true)
  end

  it 'does not recognize other methods' do
    expect(Eksek.respond_to?(:some_other_method!)).to be(false)
  end
end

RSpec.describe 'Eksek#stdout, Eksek#stderr' do
  it 'captures the stdout and stderr separatedly' do
    expect(Eksek.stdout('echo Hello')).to eq('Hello')
    expect(Eksek.stderr('echo Hello >&2')).to eq('Hello')

    outerr = Eksek.stdout_stderr('echo Hello; echo World >&2')
    expect(outerr).to eq(%w[Hello World])

    errout = Eksek.stderr_stdout('echo Hello; echo World >&2')
    expect(errout).to eq(%w[World Hello])
  end
end

RSpec.describe 'Eksek#stdouterr' do
  it 'captures the stdout and stderr together' do
    outerr = Eksek.stdouterr('echo Hello; echo World >&2')
    expect(outerr).to eq("Hello\nWorld")
  end
end

RSpec.describe 'Standard input' do
  it 'accepts a block where the stdin can be written to' do
    o = Eksek.stdout('read A B; echo $A, $B') { |i| i.write('Hi world') }
    expect(o).to eq('Hi, world')
  end

  it 'reads a String that the block returns' do
    o = Eksek.stdout('read A; echo $A') { 'Hello' }
    expect(o).to eq('Hello')
  end

  it 'reads an IO that the block returns' do
    Tempfile.open do |f|
      f.write('Hello')
      o = Eksek.stdout("cat #{f.path}") { f }
      expect(o).to eq('Hello')
    end
  end
end
