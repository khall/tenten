require 'computer'
require 'instruction'

RSpec.describe Instruction do
  describe 'constructor' do
    it 'takes a name, number of arguments, stack, program_counter, code to execute' do
      code = 'puts stack.pop'
      print_instruction = Instruction.new(:print, code)
      expect(print_instruction.name).to eq(:print)
      expect(print_instruction.code).to eq(code)
    end
  end

  describe '#to_s' do
    it 'returns PUSH 50' do
      instruction = Instruction.new('PUSH', nil)
      instruction.argument = 50
      expect(instruction.to_s).to eq('PUSH 50')
    end

    it 'returns MULT' do
      instruction = Instruction.new('MULT', nil)
      expect(instruction.to_s).to eq('MULT')
    end
  end
end
