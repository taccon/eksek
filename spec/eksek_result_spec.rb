# frozen_string_literal: true

require 'eksekuter'

RSpec.describe 'EksekResult#to_s' do
  it 'returns the stdout' do
    command = 'echo HelloStdout && echo HelloStderr >&2'
    output = "The output was: #{Eksekuter.new.run(command)}."
    expect(output).to eq('The output was: HelloStdout.')
  end
end
