require 'stack'

RSpec.describe Stack do
  let(:instruction) { Instruction.new('TEST', 'code') }
  let(:stack) do
    stack = Stack.new(12)
    stack.program_counter = 0
    stack.push_instruction(instruction)
    stack.push_instruction(instruction)
    stack.push_instruction(instruction)
    stack.push_data('data 1')
    stack
  end

  describe 'initialize' do
    it 'sets collection, size, and stack_pointer_min' do
      new_stack = Stack.new(12)
      expect(new_stack.collection.size).to eq(12)
      expect(new_stack.size).to eq(12)
      expect(new_stack.stack_pointer_min).to eq(0)
    end
  end

  describe '#pop_data' do
    it 'returns data at stack_pointer, decrements stack_pointer' do
      data = nil
      expect { data = stack.pop_data }.to change { stack.stack_pointer }.by(-1)
      expect(data).to eq('data 1')
    end
  end

  describe '#push_data' do
    it 'adds data at stack_pointer, increments stack_pointer' do
      expect { stack.push_data('data 2') }.to change { stack.stack_pointer }.by(1)
      expect(stack.collection[stack.stack_pointer]).to eq('data 2')
    end
  end

  describe '#push_instruction' do
    it 'adds instruction at program_counter, increments program_counter' do
      expect { stack.push_instruction('new instruction') }.to change { stack.program_counter }.by(1)
      expect(stack.collection[stack.program_counter - 1]).to eq('new instruction')
    end
  end

  describe '#read_instruction' do
    it 'reads instruction at program counter, increments program_counter' do
      stack.program_counter = 0
      expect(stack.read_instruction.name).to eq('TEST')
      expect(stack.program_counter).to eq(1)
      expect(stack.read_instruction.name).to eq('TEST')
      expect(stack.program_counter).to eq(2)
      expect(stack.read_instruction.name).to eq('TEST')
      expect(stack.program_counter).to eq(3)
    end
  end
end
