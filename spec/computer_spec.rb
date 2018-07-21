require 'computer'

RSpec.describe Computer do
  let(:computer) { Computer.new(100) }

  describe 'constructor' do
    it 'creates new computer with a stack of 100 addresses, with sane defaults' do
      expect(computer.stack.size).to eq(100)
    end

    it 'creates new computer with a stack of 30 addresses, with sane defaults' do
      my_computer = Computer.new(30)
      expect(my_computer.stack.size).to eq(30)
    end
  end

  describe '#set_address' do
    it 'sets address to perform operations to 20' do
      computer.set_address(20)
      expect(computer.stack.program_counter).to eq(20)
    end

    it 'sets address to perform operations to 12' do
      computer.set_address(12)
      expect(computer.stack.program_counter).to eq(12)
    end
  end

  describe '#insert' do
    it 'adds the PUSH command with argument 40 at address 20, increments program counter' do
      computer.set_address(20).insert('PUSH', 40).set_address(20)
      instruction = computer.stack.read_instruction
      expect(instruction.name).to eq('PUSH')
      expect(instruction.argument).to eq(40)
      expect(computer.stack.program_counter).to eq(21)
      expect(computer.stack.stack_pointer).to eq(20)
    end

    it 'adds the CALL command with argument 50 at address 10, increments program counter' do
      computer.set_address(10).insert('CALL', 50).set_address(10)
      instruction = computer.stack.read_instruction
      expect(instruction.name).to eq('CALL')
      expect(instruction.argument).to eq(50)
      expect(computer.stack.program_counter).to eq(11)
      expect(computer.stack.stack_pointer).to eq(10)
    end

    it 'adds multiple commands, setting the stack pointer to after the last instruction in the stack' do
      computer.set_address(10).insert('CALL', 50).insert('CALL', 40)
      computer.set_address(50).insert('PRINT')
      computer.set_address(10)
      expect(computer.stack.stack_pointer).to eq(50)
    end
  end

  describe '#execute' do
    # ensure computer.execute is wrapped to expect a SystemExit error which will be raised when a STOP instruction runs
    context 'when conducting normal operations' do
      it 'multiplies 20 and 3, gets 60' do
        computer.
          set_address(0).
          insert('PUSH', 20).
          insert('PUSH', 3).
          insert('MULT').
          insert('STOP').
          set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.pop_data).to eq(60)
        expect(computer.stack.program_counter).to eq(4)
      end

      it 'calls code at different stack location, sets program counter to 20' do
        computer.
          set_address(20).
          insert('PUSH', 100).
          insert('STOP').
          set_address(0).
          insert('CALL', 20).
          set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.pop_data).to eq(100)
        expect(computer.stack.program_counter).to eq(22)
      end

      it 'returns from calling code by setting program counter to popped value' do
        computer.
          set_address(20).
          insert('PUSH', 1).
          insert('RET').
          set_address(0).
          insert('CALL', 20).
          insert('STOP').
          set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.stack_pointer).to eq(21)
        expect(computer.stack.program_counter).to eq(2)
      end

      it 'stops program execution when executing "STOP" instruction' do
        computer.set_address(0).insert('STOP').set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.program_counter).to eq(1)
        expect(computer.stack.stack_pointer).to eq(0)
      end

      it 'pops value from the stack and prints it' do
        expect(STDOUT).to receive(:puts).with(20).once
        computer.
          set_address(0).
          insert('PUSH', 20).
          insert('PRINT').
          insert('STOP').
          set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.program_counter).to eq(3)
        expect(computer.stack.stack_pointer).to eq(2)
      end

      it 'pushes 1, 2 and 3 onto the stack' do
        computer.
          set_address(0).
          insert('PUSH', 1).
          insert('PUSH', 2).
          insert('PUSH', 3).
          insert('STOP').
          set_address(0)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.pop_data).to eq(3)
        expect(computer.stack.pop_data).to eq(2)
        expect(computer.stack.pop_data).to eq(1)
        expect(computer.stack.program_counter).to eq(4)
      end

      it 'calls twice, returns twice, multiplies four times, prints, pushes, stops' do
        expect(STDOUT).to receive(:puts).with(550).once
        expect(STDOUT).to receive(:puts).with(600).once
        expect(STDOUT).to receive(:puts).with(650).once
        computer.
          set_address(0).
          insert('PUSH', 2).
          insert('CALL', 30).
          insert('PUSH', 4).
          insert('CALL', 60).
          insert('PUSH', 650).
          insert('PRINT').
          insert('STOP').
          set_address(30).
          insert('PUSH', 10).
          insert('PUSH', 11).
          insert('MULT').
          insert('PUSH', 5).
          insert('MULT').
          insert('PRINT').
          insert('RET').
          set_address(60).
          insert('PUSH', 10).
          insert('PUSH', 12).
          insert('MULT').
          insert('PUSH', 5).
          insert('MULT').
          insert('PRINT').
          insert('RET').
          set_address(0)
        expect { computer.execute }.to raise_error(SystemExit)
      end

      it 'starts executing at 50 instead of the usual 0, multiplying to get 60' do
        computer.
          set_address(50).
          insert('PUSH', 20).
          insert('PUSH', 3).
          insert('MULT').
          insert('STOP').
          set_address(50)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.stack_pointer).to eq(54)
        expect(computer.stack.pop_data).to eq(60)
        expect(computer.stack.program_counter).to eq(54)
      end

      it 'accesses last stack position as data without an exception, multiplying to get 50' do
        computer.
          set_address(94).
          insert('PUSH', 25).
          insert('PUSH', 2).
          insert('MULT').
          insert('STOP').
          set_address(94)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.stack_pointer).to eq(98)
        expect(computer.stack.pop_data).to eq(50)
        expect(computer.stack.program_counter).to eq(98)
      end

      it 'accesses last stack position as an instruction without an exception' do
        computer.
          set_address(99).
          insert('STOP').
          set_address(99)

        expect { computer.execute }.to raise_error(SystemExit)
        expect(computer.stack.stack_pointer).to eq(99)
        expect(computer.stack.program_counter).to eq(100)
      end
    end

    context 'when an error condition occurs' do
      it 'does nothing if program counter and stack pointer are not set' do
        expect { computer.execute }.to_not raise_error
        expect(computer.stack.program_counter).to be_nil
        expect(computer.stack.stack_pointer).to be_nil
      end

      it 'steps through stack, raising "stack overflow" exception if program counter exceeds stack size' do
        expect { computer.set_address(0).insert('PUSH', 1).execute }.to raise_error('stack overflow')
      end

      it 'raises error when encountering unknown instruction' do
        expect { computer.set_address(0).insert('WUT').execute }.to raise_error(/Invalid instruction given/)
      end

      it 'overflows stack with data during execution' do
        computer.
          set_address(0).
          insert('PUSH', 2).
          insert('CALL', 50).
          insert('PUSH', 3).
          insert('PUSH', 4).
          insert('PUSH', 5).
          insert('STOP').
          set_address(95).
          insert('PUSH', 1).
          insert('PUSH', 2).
          insert('RET').
          set_address(0)

        expect { computer.execute }.to raise_error('stack overflow')
      end

      it 'overflows stack with instructions during insertion' do
        computer.
          set_address(95).
          insert('PUSH', 1).
          insert('PUSH', 2).
          insert('PUSH', 3).
          insert('PUSH', 4).
          insert('PUSH', 5)

        expect { computer.insert('PUSH', 6) }.to raise_error('stack overflow during insertion')
      end

      it 'underflows stack when attempting to access data outside of the stack size limit and data minimum' do
        computer.
          set_address(99).
          insert('PRINT').
          set_address(99)

        expect { computer.execute }.to raise_error('stack underflow')
      end

      it 'accesses before the beginning of the stack' do
        computer.
          set_address(0).
          insert('MULT').
          set_address(0)

        expect { computer.execute }.to raise_error('stack underflow')
      end
    end
  end
end
