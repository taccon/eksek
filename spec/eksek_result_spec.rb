# frozen_string_literal: true

require 'eksekuter'

RSpec.describe 'EksekResult#to_s' do
  it 'returns the stdout' do
    command = 'printf HelloStdout && printf HelloStderr >&2'
    output = "The output was: #{Eksekuter.new.run(command, capture: true)}."
    expect(output).to eq('The output was: HelloStdout.')
  end
end
