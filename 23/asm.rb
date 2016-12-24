#!/usr/bin/env ruby

require 'rubygems'

require 'curses'

class Computer #:nodoc:
  PARSE_REGEX = /(?<op>[a-z]+) (?<arg1>-?\d+|[a-d]) ?(?<arg2>-?\d+|[a-d])?/

  def initialize(registers, should_print)
    @registers = registers
    @should_print = should_print

    @ptr = 0
    @instructions = []
  end

  def <<(instruction)
    @instructions << instruction
  end

  def parse_instruction(instruction)
    match = PARSE_REGEX.match instruction
    raise "Unmatched input line: #{instruction}" if match.nil?

    instruction = {}
    instruction[:op] = match[:op].to_sym
    instruction[:arg1] = parse_arg match[:arg1]
    instruction[:arg2] = parse_arg match[:arg2]

    @instructions << instruction
  end

  def print_registers
    pairs = ['a', 'b', 'c', 'd'].zip @registers
    values = pairs.map { |p| "#{p[0]}: #{p[1]}" }
    puts "Registers: #{values.join ', ' }"
  end

  def print_state
    @instructions.each_with_index do |instruction, idx|
      print_instruction instruction, idx
      print ' | '
      print "#{(idx + 97).chr}: #{@registers[idx]}" if idx >= 0 && idx < 4
      print "\n"
    end
  end

  def run
    while @ptr < @instructions.count
      print_state if @should_print

      instruction = @instructions[@ptr]
      m = method instruction[:op]
      m.call instruction[:arg1], instruction[:arg2]

      next unless @should_print

      puts 'vvvvvvvvvvvvvvvvvvvvv'
      print_state
      puts '---------------------'
    end
  end

  private

  def cpy(arg1, arg2)
    value = resolve arg1
    idx = sym2reg arg2
    @registers[idx] = value unless idx.nil?
    @ptr += 1
  end

  def dec(arg1, _arg2)
    idx = resolve_idx arg1
    @registers[idx] -= 1
    @ptr += 1
  end

  def inc(arg1, _arg2)
    idx = resolve_idx arg1
    @registers[idx] += 1
    @ptr += 1
  end

  def jnz(arg1, arg2)
    value = resolve arg1
    offset = resolve arg2

    @ptr = value.zero? ? @ptr + 1 : @ptr + offset
  end

  def parse_arg(arg)
    if arg.nil?
      nil
    elsif ('a'..'d').cover? arg
      arg.to_sym
    else
      arg.to_i
    end
  end

  def print_instruction(instruction, idx)
    print @ptr == idx ? '> ' : '  '
    print instruction[:op].to_s.ljust(4, ' ')
    print instruction[:arg1].to_s.rjust(3, ' ')
    print instruction[:arg2].to_s.rjust(3, ' ')
  end

  def resolve(int_or_sym)
    if int_or_sym.is_a? Symbol
      idx = sym2reg int_or_sym
      @registers[idx]
    else
      int_or_sym
    end
  end

  def resolve_idx(int_or_sym)
    if int_or_sym.is_a? Symbol
      sym2reg int_or_sym
    else
      int_or_sym
    end
  end

  def sym2reg(sym)
    case sym
    when :a then 0
    when :b then 1
    when :c then 2
    when :d then 3
    end
  end

  def tgl(arg1, _arg2)
    offset = resolve arg1

    instruction = @instructions[@ptr + offset]
    @ptr += 1

    return if instruction.nil?

    if instruction[:arg2].nil?
      instruction[:op] = instruction[:op] == :inc ? :dec : :inc
    else
      instruction[:op] = instruction[:op] == :jnz ? :cpy : :jnz
    end
  end
end

register_values = ARGV.shift
registers = register_values.split(',').map(&:to_i)

should_print_value = ARGV.shift
should_print = should_print_value.nil? ? false : should_print_value == '1'

computer = Computer.new registers, should_print

ARGF.each_line do |line|
  computer.parse_instruction line
end

computer.run
computer.print_registers
