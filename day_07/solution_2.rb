# Solution for Day 7

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_07/input.txt")

# Solution logic

# OKay, so we'll parse this into a 2D array..
# Then we'll find S in teh first line, and store the index.
# For the next line, we'll check if it hits a splitter, and if so, we'll store the new indices.

splitter_map = Array.new(lines.length) { Array.new(lines[0].length, ".") }
start_index = nil

lines.each_with_index do |line, col_index|
  splitter_map[col_index] = line.split("")
end

start_index = splitter_map[0].index("S")
number_of_rows = lines.length
number_of_columns = lines[0].length

# Okay, next up, for each row, we iterate and adjust the tracked indices.
tachyon_indices = Array.new(number_of_columns, 0)
tachyon_indices[start_index] = 1
tachyon_split_count = 0

# Okay, same as before, but we need to track how many beams are in each index.
splitter_map.each_with_index do |row, row_index|
  if row_index == 0 #SKip the first row.
    new_tachyon_indices = tachyon_indices
  else
    new_tachyon_indices = Array.new(number_of_columns, 0)
    tachyon_indices.each_with_index do |count, i|
      # So now, we need to count the total number of beams at each index.
      # So we just keep track, and instead of saying there is a beam here, we say there are X beams here.
      if row[i] == "^"
        new_tachyon_indices[i - 1] = new_tachyon_indices[i - 1] + count
        new_tachyon_indices[i + 1] = new_tachyon_indices[i + 1] + count
        tachyon_split_count += 1
      else
        new_tachyon_indices[i] = new_tachyon_indices[i] + count
      end
    end
  end
  # new_tachyon_indices.uniq! Ugh, tooooo slow.
  tachyon_indices = new_tachyon_indices
  # puts "Completed row #{row_index} of #{number_of_rows}"
end

puts "Tachyon beam count: #{tachyon_indices.sum}"
puts "Tachyon split count: #{tachyon_split_count}"
