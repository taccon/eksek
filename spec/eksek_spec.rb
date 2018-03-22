# frozen_string_literal: true

require 'tempfile'

require 'eksek'

RSpec.describe 'eksek#success?' do
  it 'returns true or false' do
    expect(eksek('true').success?).to be(true)
    expect(eksek('exit 1').success?).to be(false)
  end
end

RSpec.describe '#eksek!' do
  it 'fails on :eksek! when appropriatly' do
    expect { eksek! 'true' }.not_to raise_error
    expect { eksek! 'exit 1' }.to raise_error EksekError
  end
end

RSpec.describe 'eksek#exit' do
  it 'returns the exit code' do
    expect(eksek('exit 0').exit_code).to be(0)
    expect(eksek('exit 1').exit_code).to be(1)
    expect(eksek('exit 7').exit_code).to be(7)
  end
end

RSpec.describe 'eksek#stdout, eksek#stderr' do
  it 'captures the stdout and stderr separately' do
    expect(eksek('echo Hello').stdout).to eq('Hello')
    expect(eksek('echo Hello >&2').stderr).to eq('Hello')
  end
end

RSpec.describe 'eksek#stdout, eksek#stderr, eksek#exit_code, eksek!' do
  it 'lets you combine eksek! and stdout/stderr/exit_code' do
    expect(eksek!('echo Hello').stdout).to eq('Hello')
    expect(eksek!('echo Hello >&2').stderr).to eq('Hello')
    expect(eksek!('exit 0').exit_code).to be(0)
    expect { eksek!('exit 1').stdout }.to raise_error EksekError
  end
end

RSpec.describe 'Standard input' do
  it 'accepts a block where the stdin can be written to' do
    o = eksek('read A B; echo $A, $B') { |i| i.write('Hi world') }
    expect(o.stdout).to eq('Hi, world')
  end

  it 'reads a String that the block returns' do
    o = eksek('read A; echo $A') { 'Hello' }
    expect(o.stdout).to eq('Hello')
  end

  it 'reads an IO that the block returns' do
    file = Tempfile.open
    file.write('Hello')
    file.close

    File.open(file.path) do |f|
      o = eksek('read A; echo $A!!!') { f }
      expect(o.stdout).to eq('Hello!!!')
    end

    file.unlink
  end
end
