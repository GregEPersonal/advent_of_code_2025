# Solution for Day 3

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_03/input.txt")

# Find max_joltage of a line.
def max_joltage(line)
  # First, find the max number on the line that isn't in the last spot.
  first_digit = 0
  9.downto(0) do |max_number|
    if line[0..-2].include?(max_number.to_s)
      first_digit = max_number
      break
    end
  end

  # Then, we find the first instance of the max number, and return the highest number after taht in the string.
  second_digit = 0
  starting_index = line.index(first_digit.to_s) + 1
  9.downto(0) do |max_number|
    if line[starting_index..-1].include?(max_number.to_s)
      second_digit = max_number
      break
    end
  end

  return first_digit * 10 + second_digit
end

# Solution logic
#
total_joltage = 0

lines.each do |line|
  total_joltage += max_joltage(line)
end

puts total_joltage
