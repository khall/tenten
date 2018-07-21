require 'nil_instruction'

RSpec.describe NilInstruction do
  let(:nil_instruction) { NilInstruction.instance }

  describe 'constructor' do
    it 'takes a name, number of arguments, stack, program_counter, code to execute' do
      expect(nil_instruction.name).to eq('NOP')
    end
  end

  describe '#to_s' do
    it 'returns NOP' do
      expect(nil_instruction.to_s).to eq('NOP')
    end
  end
end
