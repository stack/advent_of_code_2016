#!/usr/bin/env ruby

require 'rubygems'

require 'curses'

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

def toggle(instructions, ptr, value)
  instruction = instructions[ptr + value]
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
end

registers = [0, 0, 1, 0]

instructions = ARGF.each_line.map do |line|
  if line =~ /cpy (\d+) ([a-d])/
    { id: :cpy, arg1: $1.to_i, arg2: $2.to_sym }
  elsif line =~ /cpy ([a-d]) ([a-d])/
    { id: :cpy2, arg1: $1.to_sym, arg2: $2.to_sym }
  elsif line =~ /inc ([a-d])/
    { id: :inc, arg1: $1.to_sym }
  elsif line =~ /dec ([a-d])/
    { id: :dec, arg1: $1.to_sym }
  elsif line =~ /jnz ([a-d]) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    { id: :jnz, arg1: $1.to_sym, arg2: value }
  elsif line =~ /jnz (\d+) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    { id: :jnz2, arg1: $1.to_i, arg2: value }
  elsif line =~ /tgl ([a-d])/
    { id: :tgl, arg1: $1.to_sym }
  else
    raise "Unhandled input #{line}"
  end
end

ptr = 0

Curses.init_screen
window = Curses::Window.new(Curses.cols, Curses.lines, 0, 0)

def print_screen(window, instructions, registers, ptr)
  window.clear

  instructions.each_with_index do |instruction, idx|
    window.setpos idx, 0

    window.addstr (idx == ptr) ? '> ' : '  '
    window.addstr instruction[:id].to_s.ljust(5, ' ')
    window.addstr instruction[:arg1].to_s.ljust(5, ' ')
    window.addstr instruction[:arg2].to_s.ljust(5, ' ') unless instruction[:arg2].nil?
  end

  window.setpos 0, 20
  window.addstr "a: #{registers[0]}"
  window.setpos 1, 20
  window.addstr "b: #{registers[1]}"
  window.setpos 2, 20
  window.addstr "c: #{registers[2]}"
  window.setpos 3, 20
  window.addstr "d: #{registers[3]}"

  window.refresh
end

while ptr < instructions.count
  instruction = instructions[ptr]

  puts instruction

  case instruction[:id]
  when :cpy
    idx = sym2reg instruction[:arg2]
    registers[idx] = instruction[:arg1] unless idx.nil?
    ptr += 1
  when :cpy2
    dest = sym2reg instruction[:arg2]
    src = sym2reg instruction[:arg1]

    if !dest.nil? && !src.nil?
      registers[dest] = registers[src]
    end

    ptr += 1
  when :inc
    idx = sym2reg instruction[:arg1]
    registers[idx] += 1 unless idx.nil?
    ptr += 1
  when :dec
    idx = sym2reg instruction[:arg1]
    registers[idx] -= 1 unless idx.nil?
    ptr += 1
  when :jnz
    idx = sym2reg instruction[:arg1]

    if idx.nil?
      puts 'JNZ Invalid'
      ptr += 1
    else
      value = registers[idx]
    
      puts "JNZ #{value}"
      if value == 0
        ptr += 1
      else
        ptr += instruction[:arg2]
      end
    end
  when :jnz2
    if instruction[:arg1] == 0
      ptr += 1
    else
      ptr += instruction[:arg2]
    end
  when :tgl
    idx = sym2reg instruction[:arg1]
    value = registers[idx]

    toggle instructions, ptr, value
    ptr += 1
  else
    raise "Unhandled instruction #{instruction[:id]}"
  end

  # print_screen window, instructions, registers, ptr
  # sleep 2

end

window.close
