require_relative 'nil_instruction'

# stack built to handle various error conditions and special push/pop logic relating to data and instructions
class Stack
  attr_reader :collection, :stack_pointer_min, :size, :stack_pointer
  attr_accessor :program_counter

  def initialize(size)
    @collection = Array.new(size) { NilInstruction.instance }
    @size = size
    @stack_pointer_min = 0
  end

  def pop_data
    raise 'stack underflow' if stack_pointer < stack_pointer_min
    data = collection[stack_pointer]
    @collection[stack_pointer] = NilInstruction.instance
    @stack_pointer -= 1
    data
  end

  def push_data(new_data)
    @stack_pointer += 1
    raise 'stack overflow' if stack_pointer >= size
    @collection[stack_pointer] = new_data
  end

  def push_instruction(instruction)
    raise 'stack overflow during insertion' if program_counter >= size
    @collection[program_counter] = instruction
    @program_counter += 1
    update_stack_pointer_min
  end

  def read_instruction
    instruction = collection[program_counter]
    @program_counter += 1
    instruction
  end

  private

  def update_stack_pointer_min
    @stack_pointer_min = program_counter if program_counter >= stack_pointer_min
    @stack_pointer = stack_pointer_min - 1 # first data push will increment beforehand
  end
end
