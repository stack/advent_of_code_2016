#!/usr/bin/env ruby

require 'rubygems'

require 'curses'

class Computer #:nodoc:
  def initialize
    @ptr = 0
    @instructions = []
    @registers = [0, 0, 1, 0]
  end

  def <<(instruction)
    @instructions << instruction
  end

  def print_state
    @instructions.each_with_index do |instruction, idx|
      print @ptr == idx ? "> " : "  "
      print instruction[:id].to_s.ljust(5, ' ')
      print instruction[:arg1].to_s.ljust(4, ' ')
      print instruction[:arg2].to_s.ljust(4, ' ')
      print '| '

      if idx == 0
        print "a: #{@registers[0]}"
      elsif idx == 1
        print "b: #{@registers[1]}"
      elsif idx == 2
        print "c: #{@registers[2]}"
      elsif idx == 3
        print "d: #{@registers[3]}"
      end

      puts
    end
  end

  def run
    while @ptr < @instructions.count
      print_state

      instruction = @instructions[@ptr]
      perform instruction

      puts 'vvvvvvvvvvvvvvvvvvvvv'
      print_state
      puts '---------------------'
    end
  end

  private

  def cpy(arg1, arg2)
    idx = sym2reg arg2
    @registers[idx] = arg1
    @ptr += 1
  end

  def cpy2(arg1, arg2)
    dest = sym2reg arg2
    src = sym2reg arg1
    @registers[dest] = @registers[src]
    @ptr += 1
  end

  def dec(arg1)
    idx = sym2reg arg1
    @registers[idx] -= 1
    @ptr += 1
  end

  def inc(arg1)
    idx = sym2reg arg1
    @registers[idx] += 1
    @ptr += 1
  end

  def jnz(arg1, arg2)
    idx = sym2reg arg1
    value = @registers[idx]

    if value == 0
      @ptr += 1
    else
      @ptr += arg2
    end
  end

  def jnz2(arg1, arg2)
    if arg1 == 0
      @ptr += 1
    else
      @ptr += arg2
    end
  end

  def perform(instruction)
    case instruction[:id]
    when :cpy then cpy(instruction[:arg1], instruction[:arg2])
    when :cpy2 then cpy2(instruction[:arg1], instruction[:arg2])
    when :dec then dec(instruction[:arg1])
    when :inc then inc(instruction[:arg1])
    when :jnz then jnz(instruction[:arg1], instruction[:arg2])
    when :jnz2 then jnz2(instruction[:arg1], instruction[:arg2])
    when :tgl then tgl(instruction[:arg1])
    else
      raise "Invalid instruction: #{instruction[:id]}"
    end
  end

  def sym2reg(sym)
    case sym
    when :a then 0
    when :b then 1
    when :c then 2
    when :d then 3
    else
      nil
    end
  end

  def tgl(arg1)
    idx = sym2reg arg1
    offset = @registers[idx]

    instruction = @instructions[@ptr + offset]
    return if instruction.nil?

    if instruction.keys.count == 2
      if instruction[:id] == :inc
        instruction[:id] = :dec
      else
        instruction[:id] = :inc
      end
    else
      if instruction[:id] == :jnz
        instruction[:id] = :cpy
      else
        instruction[:id] = :jnz
      end
    end

    @ptr += 1
  end
end

computer = Computer.new

ARGF.each_line do |line|
  if line =~ /cpy (\d+) ([a-d])/
    computer << { id: :cpy, arg1: $1.to_i, arg2: $2.to_sym }
  elsif line =~ /cpy ([a-d]) ([a-d])/
    computer << { id: :cpy2, arg1: $1.to_sym, arg2: $2.to_sym }
  elsif line =~ /inc ([a-d])/
    computer << { id: :inc, arg1: $1.to_sym }
  elsif line =~ /dec ([a-d])/
    computer << { id: :dec, arg1: $1.to_sym }
  elsif line =~ /jnz ([a-d]) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    computer << { id: :jnz, arg1: $1.to_sym, arg2: value }
  elsif line =~ /jnz (\d+) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    computer << { id: :jnz2, arg1: $1.to_i, arg2: value }
  elsif line =~ /tgl ([a-d])/
    computer << { id: :tgl, arg1: $1.to_sym }
  else
    raise "Unhandled input #{line}"
  end
end

computer.run
