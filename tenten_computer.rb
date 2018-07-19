require_relative 'lib/computer'

PRINT_TENTEN_BEGIN = 50
MAIN_BEGIN = 0

def main
  # Create new computer with a stack of 100 addresses
  computer = Computer.new(100)
  # Instructions for the print_tenten function
  computer.set_address(PRINT_TENTEN_BEGIN).insert('MULT').insert('PRINT').insert('RET')
  # The start of the main function
  computer.set_address(MAIN_BEGIN).insert('PUSH', 1009).insert('PRINT')
  # Return address for when print_tenten function finishes
  computer.insert('PUSH', 6)
  # Setup arguments and call print_tenten
  computer.insert('PUSH', 101).insert('PUSH', 10).insert('CALL', PRINT_TENTEN_BEGIN)
  # Stop the program
  computer.insert('STOP')
  computer.set_address(MAIN_BEGIN).execute
end
main
