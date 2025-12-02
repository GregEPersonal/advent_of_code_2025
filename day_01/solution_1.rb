# Solution for Day 1

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_01/input.txt")

#Parse the line
def parse_line(line)
  sign = line[0]
  amount = line[1..-1].to_i
  return sign, amount
end

# Solution logic
starting_position = 50
zero_count = 0

lines.each do |line|
  sign, amount = parse_line(line)
  if sign == "L"
    starting_position = (starting_position - amount) % 100
  else
    starting_position = (starting_position + amount) % 100
  end
  if starting_position == 0
    zero_count += 1
  end
end

puts zero_count
