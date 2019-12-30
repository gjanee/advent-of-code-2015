# --- Day 23: Opening the Turing Lock ---
#
# Little Jane Marie just got her very first computer for Christmas
# from some unknown benefactor.  It comes with instructions and an
# example program, but the computer itself seems to be malfunctioning.
# She's curious what the program does, and would like you to help her
# run it.
#
# The manual explains that the computer supports two registers and six
# instructions (truly, it goes on to remind the reader, a
# state-of-the-art technology).  The registers are named a and b, can
# hold any non-negative integer, and begin with a value of 0.  The
# instructions are as follows:
#
# - hlf r sets register r to half its current value, then continues
#   with the next instruction.
# - tpl r sets register r to triple its current value, then continues
#   with the next instruction.
# - inc r increments register r, adding 1 to it, then continues with
#   the next instruction.
# - jmp offset is a jump; it continues with the instruction offset
#   away relative to itself.
# - jie r, offset is like jmp, but only jumps if register r is even
#   ("jump if even").
# - jio r, offset is like jmp, but only jumps if register r is 1
#   ("jump if one", not odd).
#
# All three jump instructions work with an offset relative to that
# instruction.  The offset is always written with a prefix + or - to
# indicate the direction of the jump (forward or backward,
# respectively).  For example, jmp +1 would simply continue with the
# next instruction, while jmp +0 would continuously jump back to
# itself forever.
#
# The program exits when it tries to run an instruction beyond the
# ones defined.
#
# For example, this program sets a to 2, because the jio instruction
# causes it to skip the tpl instruction:
#
# inc a
# jio a, +2
# tpl a
# inc a
#
# What is the value in register b when the program in your puzzle
# input is finished executing?

class Instruction

  attr_reader :operator, :register, :offset

  def initialize(operator, register:nil, offset:nil)
    @operator, @register, @offset = operator, register, offset
  end

end

Program = open("23.in").map {|l|
  t = l.split
  if t[0].start_with?("j")
    if t[0].start_with?("ji")
      Instruction.new(t[0], register:t[1][0], offset:t[2].to_i)
    else
      Instruction.new(t[0], offset:t[1].to_i)
    end
  else
    Instruction.new(t[0], register:t[1])
  end
}

def run(r)
  ip = 0
  while 0 <= ip && ip < Program.length
    i = Program[ip]
    case i.operator
    when "hlf"
      r[i.register] /= 2
      ip += 1
    when "tpl"
      r[i.register] *= 3
      ip += 1
    when "inc"
      r[i.register] += 1
      ip += 1
    when "jmp"
      ip += i.offset
    when "jie"
      ip += (r[i.register]%2 == 0 ? i.offset : 1)
    when "jio"
      ip += (r[i.register] == 1 ? i.offset : 1)
    end
  end
end

r = { "a" => 0, "b" => 0 }
run(r)
puts r["b"]

# --- Part Two ---
#
# The unknown benefactor is very thankful for releasi-- er, helping
# little Jane Marie with her computer.  Definitely not to distract
# you, what is the value in register b after the program is finished
# executing if register a starts as 1 instead?

r = { "a" => 1, "b" => 0 }
run(r)
puts r["b"]
