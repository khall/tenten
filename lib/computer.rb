require_relative 'instruction'
require_relative 'nil_instruction'
require_relative 'stack'

# A computer with a set of instructions defined by ruby lambdas
# stack contains all instructions and data
# program_counter is a stack index pointing to the next instruction to execute
# stack_pointer points to the last piece of data. stack_pointer - 1 is where the stack pointer initially begins
class Computer
  attr_reader :instructions, :stack

  def initialize(stack_size)
    @stack = Stack.new(stack_size)
    load_instructions
  end

  def set_address(address)
    stack.program_counter = address
    self
  end

  def insert(command, argument = nil)
    @stack.push_instruction(find_instruction(command, argument))
    self
  end

  def execute
    # puts "PC: #{program_counter} -- SP: #{stack_pointer} -- stack: #{stack}"
    return if cannot_execute?

    while no_overflow?
      instruction = stack.read_instruction
      instruction.code.call(instruction.argument)
    end

    raise 'stack overflow'
  end

  private

  def load_instructions
    @instructions = {
      'CALL' => Instruction.new('CALL', call_code),
      'MULT' => Instruction.new('MULT', mult_code),
      'PRINT' => Instruction.new('PRINT', print_code),
      'PUSH' => Instruction.new('PUSH', push_code),
      'RET' => Instruction.new('RET', ret_code),
      'STOP' => Instruction.new('STOP', stop_code),
      'NOP' => nil_instruction
    }
  end

  def find_instruction(name, argument)
    instruction = instructions[name]
    raise "Invalid instruction given: #{name}. Choices are: #{@instructions.values.map(&:name)}" if instruction.nil?
    instruction.argument = argument
    argument.nil? ? instruction : instruction.dup # dup or else we can't have unique args
  end

  def nil_instruction
    NilInstruction.instance
  end

  def call_code
    ->(arg) { stack.program_counter = arg - 1 }
  end

  def mult_code
    lambda do |_arg|
      stack.push_data(stack.pop_data * stack.pop_data)
    end
  end

  def print_code
    lambda do |_arg|
      puts stack.pop_data
    end
  end

  def push_code
    lambda do |arg|
      stack.push_data(arg)
    end
  end

  def ret_code
    lambda do |_arg|
      stack.program_counter = stack.pop_data
    end
  end

  def stop_code
    ->(_arg) { exit }
  end

  def last_data_index
    stack_pointer - 1
  end

  def cannot_execute?
    stack.program_counter.nil? || stack.stack_pointer.nil?
  end

  def no_overflow?
    stack.program_counter < stack.size && stack.stack_pointer <= stack.size
  end
end
