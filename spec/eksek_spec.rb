# frozen_string_literal: true

require 'tempfile'

require 'eksek'

RSpec.describe Eksek, '#success?' do
  it 'returns true or false' do
    expect(Eksek.ute('true').success?).to be(true)
    expect(Eksek.ute('exit 1').success?).to be(false)
  end
end

RSpec.describe Eksek, '#success!' do
  it 'fails on :success! when appropriatly' do
    expect { Eksek.ute('true').success! }.not_to raise_error
    expect { Eksek.ute('exit 1').success! }.to raise_error EksekError
  end
end

RSpec.describe Eksek, '#exit' do
  it 'returns the exit code' do
    expect(Eksek.ute('exit 0').exit_code).to be(0)
    expect(Eksek.ute('exit 1').exit_code).to be(1)
    expect(Eksek.ute('exit 7').exit_code).to be(7)
  end
end

RSpec.describe 'Eksek#stdout, Eksek#stderr' do
  it 'captures the stdout and stderr separately' do
    expect(Eksek.ute('echo Hello').stdout).to eq('Hello')
    expect(Eksek.ute('echo Hello >&2').stderr).to eq('Hello')
  end
end

RSpec.describe 'Eksek#stdout, Eksek#stderr, Eksek#exit_code, Eksek#success!' do
  it 'lets you combine success! and stdout/stderr/exit_code' do
    expect(Eksek.ute('echo Hello').success!.stdout).to eq('Hello')
    expect(Eksek.ute('echo Hello >&2').success!.stderr).to eq('Hello')
    expect(Eksek.ute('exit 0').success!.exit_code).to be(0)
    expect { Eksek.ute('exit 1').success!.stdout }.to raise_error EksekError
  end
end

RSpec.describe 'Standard input' do
  it 'accepts a block where the stdin can be written to' do
    o = Eksek.ute('read A B; echo $A, $B') { |i| i.write('Hi world') }
    expect(o.stdout).to eq('Hi, world')
  end

  it 'reads a String that the block returns' do
    o = Eksek.ute('read A; echo $A') { 'Hello' }
    expect(o.stdout).to eq('Hello')
  end

  it 'reads an IO that the block returns' do
    Tempfile.open do |f|
      f.write('Hello')
      o = Eksek.ute("cat #{f.path}") { f }
      expect(o.stdout).to eq('Hello')
    end
  end
end

RSpec.describe Eksek, '#run' do
  it 'lets you use either Eksek.ute or Eksek.run' do
    expect(Eksek.ute('true').success?).to be(Eksek.run('true').success?)
    expect(Eksek.ute('exit 1').success?).to be(Eksek.run('exit 1').success?)
  end
end
