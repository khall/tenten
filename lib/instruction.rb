# basic instruction to be run via the computer class
class Instruction
  attr_reader :code, :name
  attr_accessor :argument

  def initialize(name, code)
    @name = name
    @code = code
  end

  def to_s
    "#{name} #{argument}".strip
  end
  alias inspect to_s
end
