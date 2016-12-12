#!/usr/bin/env ruby

def sym2reg(sym)
  case sym
  when :a then 0
  when :b then 1
  when :c then 2
  when :d then 3
  else
    raise "Unsupported sym #{sym}"
  end
end

registers = [0, 0, 1, 0]

instructions = ARGF.each_line.map do |line|
  if line =~ /cpy (\d+) ([a-d])/
    { id: :cpy, value: $1.to_i, dest: $2.to_sym }
  elsif line =~ /cpy ([a-d]) ([a-d])/
    { id: :cpy2, src: $1.to_sym, dest: $2.to_sym }
  elsif line =~ /inc ([a-d])/
    { id: :inc, value: $1.to_sym }
  elsif line =~ /dec ([a-d])/
    { id: :dec, value: $1.to_sym }
  elsif line =~ /jnz ([a-d]) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    { id: :jnz, src: $1.to_sym, dist: value }
  elsif line =~ /jnz (\d+) (-?)(\d+)/
    value = $3.to_i * ($2 == '-' ? -1 : 1)
    { id: :jnz2, src: $1.to_i, dist: value }
  else
    raise "Unhandled input #{line}"
  end
end

ptr = 0
while ptr < instructions.count
  instruction = instructions[ptr]

  puts instruction

  case instruction[:id]
  when :cpy
    idx = sym2reg instruction[:dest]
    registers[idx] = instruction[:value]
    ptr += 1
  when :cpy2
    dest = sym2reg instruction[:dest]
    src = sym2reg instruction[:src]
    registers[dest] = registers[src]
    ptr += 1
  when :inc
    idx = sym2reg instruction[:value]
    registers[idx] += 1
    ptr += 1
  when :dec
    idx = sym2reg instruction[:value]
    registers[idx] -= 1
    ptr += 1
  when :jnz
    idx = sym2reg instruction[:src]
    value = registers[idx]
    
    if value == 0
      ptr += 1
    else
      ptr += instruction[:dist]
    end
  when :jnz2
    if instruction[:src] == 0
      ptr += 1
    else
      ptr += instruction[:dist]
    end
  else
    raise "Unhandled instruction #{instruction[:id]}"
  end

  puts "a: #{registers[0]}"
  puts "b: #{registers[1]}"
  puts "c: #{registers[2]}"
  puts "d: #{registers[3]}"
  puts "ptr: #{ptr}"
end
