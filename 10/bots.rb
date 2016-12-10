#!/usr/bin/env ruby

class Receiver #:nodoc:
  attr_reader :id
  attr_reader :values

  def initialize(id, listener)
    @id = id
    @listener = listener
    @values = []
  end

  def give(value)
    @values << value
  end

  def process
  end

  def dot_id
    raise NotImplementedError
  end
end

class Bot < Receiver #:nodoc:
  attr_accessor :low, :high

  def process
    return unless @values.count == 2
    raise "Bot #{@id} does not have low" if @low.nil?
    raise "Bot #{@id} does not have high" if @high.nil?

    values = @values.sort
    @values = []

    @listener.bot_comparing(self, values)

    @low.give(values.shift)
    @high.give(values.shift)

    @low.process
    @high.process
  end

  def dot_id
    "bot_#{@id}"
  end
end

class Output < Receiver #:nodoc:
  def dot_id
    "output_#{@id}"
  end
end

class Factory #:nodoc:
  attr_reader :outputs

  def initialize
    @bots = []
    @outputs = []
  end

  def assign_high_bot(bot_id, high_id)
    bot = get_bot bot_id
    high = get_bot high_id
    bot.high = high
  end

  def assign_high_output(bot_id, high_id)
    bot = get_bot bot_id
    high = get_output high_id
    bot.high = high
  end

  def assign_low_bot(bot_id, low_id)
    bot = get_bot bot_id
    low = get_bot low_id
    bot.low = low
  end

  def assign_low_output(bot_id, low_id)
    bot = get_bot bot_id
    low = get_output low_id
    bot.low = low
  end

  def bot_comparing(bot, values)
    puts "Bot #{bot.id} is comparing #{values.inspect}"
  end

  def give(bot_id, value)
    bot = get_bot bot_id
    bot.give value
    bot.process
  end

  def dot_graph
    output = "digraph {\n"
    @bots.each do |bot|
      output += "#{bot.dot_id} -> #{bot.low.dot_id}\n" unless bot.low.nil?
      output += "#{bot.dot_id} -> #{bot.high.dot_id}\n" unless bot.high.nil?
    end

    output += "}\n"
  end

  private

  def get_bot(id)
    @bots[id] = Bot.new(id, self) if @bots[id].nil?
    @bots[id]
  end

  def get_output(id)
    @outputs[id] = Output.new(id, self) if @outputs[id].nil?
    @outputs[id]
  end
end

# Start with an empty factory
factory = Factory.new

# Parse the input
values = []
ARGF.each_line do |line|
  if line =~ /value (\d+) goes to bot (\d+)/
    values << { value: $1.to_i, bot: $2.to_i }
  elsif line =~ /bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/
    bot_id = $1.to_i
    low_id = $3.to_i
    high_id = $5.to_i

    if $2 == 'bot'
      factory.assign_low_bot(bot_id, low_id)
    elsif $2 == 'output'
      factory.assign_low_output(bot_id, low_id)
    else
      raise "Invalid low type #{$2}"
    end

    if $4 == 'bot'
      factory.assign_high_bot(bot_id, high_id)
    elsif $4 == 'output'
      factory.assign_high_output(bot_id, high_id)
    else
      raise "Invalid high type #{$4}"
    end
  else
    raise "Invalid line: #{line}"
  end
end

values.each do |value|
  factory.give value[:bot], value[:value]
end

factory.outputs.each do |output|
  puts "Output #{output.id} -> #{output.values}"
end


File.write 'factory.gv', factory.dot_graph
