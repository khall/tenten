require 'singleton'
require_relative 'instruction'

# no-op instruction
class NilInstruction < Instruction
  include Singleton

  def initialize
    @name = 'NOP'
    @code = ->(_arg) {} # do nothing
  end
end
