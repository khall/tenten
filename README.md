# Tenten interview assignment

Creates a simulated computer with a minimal instruction set that can execute code.

## How to run

ruby tenten_computer.rb

## Requirements

Developed with Ruby 2.4.2p198

## Proposed architecture improvements

This solution works but it allows for the stack pointer to reach the instructions instead of remaining in the data
portion of the stack. Ideally a new Stack object would be created that would handle all limit checks which would
simultaneously clean up the Computer class by hiding implementation details.

Also making NilInstruction a true singleton class would be nice.