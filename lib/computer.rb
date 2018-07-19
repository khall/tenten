require_relative 'instruction'
require_relative 'nil_instruction'

# A computer with a set of instructions defined by ruby lambdas
# stack contains all instructions and data
# program_counter is a stack index pointing to the next instruction to execute
# stack_pointer points to the next empty data location. stack_pointer - 1 (last_data_index) gets the last piece of data
class Computer
  attr_reader :instructions, :program_counter, :stack, :stack_pointer, :stack_size

  def initialize(stack_size)
    @stack_size = stack_size
    # TODO: make this array an actual stack that utilizes a stack pointer so we can pop and push easier
    @stack = Array.new(stack_size) { nil_instruction }
    load_instructions
  end

  def set_address(address)
    @program_counter = address
    self
  end

  def insert(command, argument = nil)
    @stack[program_counter] = find_instruction(command, argument)
    @program_counter += 1

    # set stack pointer to the location following the largest instruction
    @stack_pointer = program_counter if stack_pointer.nil? || program_counter > stack_pointer
    raise 'stack overflow during insertion' if program_counter > stack_size || stack_pointer > stack_size
    self
  end

  def execute
    return if cannot_execute?

    while program_counter < stack_size && stack_pointer <= stack_size
      instruction = stack[program_counter]
      return if instruction.name == 'STOP'
      instruction.code.call(instruction.argument)
      @program_counter += 1
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
      # TODO: This STOP instruction would work but then the tests get more complicated, so for now let's leave the
      # "break if STOP" code in #execute
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
    @nil_instruction ||= NilInstruction.new
  end

  def call_code
    ->(arg) { @program_counter = arg - 1 }
  end

  def mult_code
    lambda do |_arg|
      @stack[stack_pointer - 2] = stack[last_data_index] * stack[stack_pointer - 2]
      @stack[last_data_index] = nil_instruction
      @stack_pointer -= 1
    end
  end

  def print_code
    lambda do |_arg|
      puts stack[last_data_index]
      @stack[last_data_index] = nil_instruction
      @stack_pointer -= 1
    end
  end

  def push_code
    lambda do |arg|
      # we allow stack_pointer to reach 100, but you can't write there
      raise 'stack overflow' if stack_pointer >= stack_size
      @stack[stack_pointer] = arg
      @stack_pointer += 1
    end
  end

  def ret_code
    lambda do |_arg|
      @program_counter = stack[last_data_index] - 1
      stack[last_data_index] = nil_instruction
      @stack_pointer -= 1
    end
  end

  def stop_code
    ->(_arg) { exit }
  end

  def last_data_index
    stack_pointer - 1
  end

  def cannot_execute?
    program_counter.nil? || stack_pointer.nil?
  end

  def stack_overflow?
    program_counter > stack_size || stack_pointer > stack_size
  end
end
