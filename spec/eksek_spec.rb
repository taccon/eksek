# frozen_string_literal: true

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
  it 'recognizes all methods and combinations' do
    expect(Eksek.respond_to?(:stdout)).to be(0)
    expect(Eksek.respond_to?(:stdout)).to be(0)
    expect(Eksek.respond_to?(:stdout)).to be(0)
  end
end

RSpec.describe Eksek, '#method_missing' do
  it 'responds to combinations of :stdout/:stderr' do
    expect(Eksek.stdout('echo Hello')).to eq('Hello')
    expect(Eksek.stderr('echo Hello >&2')).to eq('Hello')

    outerr = Eksek.stdout_stderr('echo Hello; echo World >&2')
    expect(outerr).to eq(%w[Hello World])

    errout = Eksek.stderr_stdout('echo Hello; echo World >&2')
    expect(errout).to eq(%w[World Hello])
  end

  it 'accepts a block where the stdin can be written to' do
    o = Eksek.stdout('read A B; echo $A, $B') { |i| i.write('Hi world') }
    expect(o).to eq('Hi, world')
  end

  it 'reads any String or IO into the stdin' do
    o = Eksek.stdout('read A; echo $A') { 'Hello' }
    expect(o).to eq('Hello')
  end
end
