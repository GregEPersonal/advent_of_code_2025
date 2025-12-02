# Solution for Day 2

require "pry"
require_relative "../utils"

# Read input lines
lines = read_input_lines("day_02/input.txt")

# Solution logic
#
bad_line_array = []

lines.each do |line|
  ranges = line.split(",")
  ranges.each do |range|
    low, high = range.split("-").map(&:to_i)
    for i in low..high
      string_i = i.to_s
      str_length = string_i.length
      if str_length % 2 == 1
        next
      else
        # TAke first half of the number and compare to second half
        first_half = string_i[0..(str_length / 2 - 1)]
        second_half = string_i[(str_length / 2)..-1]
        # puts "First half: #{first_half}, Second half: #{second_half}, Match? #{first_half == second_half}"
        if first_half == second_half
          bad_line_array << i
        end
      end
    end
    puts "Completed range: #{range}"
  end
end

# SUm the bad_line array
puts bad_line_array.sum
