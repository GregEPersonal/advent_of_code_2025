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
      # SEries of hardcoded given the lines dont get that long.
      for repeat_length in 1..str_length / 2
        if str_length % repeat_length == 0
          repeats = str_length / repeat_length
          # TAke first half of the number and compare to second half
          first_third = string_i[0..repeat_length - 1]
          new_string = first_third * repeats
          if new_string == string_i
            bad_line_array << i
            break # break out of the for loop, this one matches.
          end
        end
      end
    end
    puts "Completed range: #{range}"
  end
end

# SUm the bad_line array
# puts bad_line_array.join(", ")
puts bad_line_array.sum
