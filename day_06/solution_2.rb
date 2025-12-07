# Solution for Day 6

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_06/input.txt")

# Solution logic
new_lines = []
lines.each do |line|
  new_line = []
  line.split(" ").each do |chars|
    if !chars.empty?
      new_line << chars
    end
  end
  new_lines << new_line
end

max_char_length_array = Array.new(new_lines[0].length, 0)

new_lines[0].each_with_index do |char, col_index|
  current_max = 0
  new_lines.length.times do |row_index|
    length = new_lines[row_index][col_index].length
    if length > current_max
      current_max = length
    end
  end
  max_char_length_array[col_index] = current_max
end

puts max_char_length_array.join(" ")

# Okay, so we are going to chunk up each line by the max character length per row,
# And then for each column do some chars shenanigans.

lines_as_strings = Array.new(new_lines.length) { Array.new(new_lines[0].length) }
lines.each_with_index do |line, row_index|
  current_index = 0
  max_char_length_array.each_with_index do |max_char_length, col_index|
    lines_as_strings[row_index][col_index] = line[current_index..current_index + max_char_length]
    current_index += max_char_length + 1
  end
end

puts lines_as_strings[0][3]

running_total = 0

lines_as_strings[0].length.times do |col_index|
  operator = new_lines[new_lines.length - 1][col_index]

  char_length = max_char_length_array[col_index]
  if operator == "+"
    col_total = 0
  else
    col_total = 1
  end

  # Iterate over each character in the column.
  for i in 0..char_length - 1
    # Iterate over each line in the column.
    string = ""
    for j in 0..lines_as_strings.length - 1
      string_char = lines_as_strings[j][col_index].chars[i]
      string += string_char
    end
    if operator == "+"
      col_total += string.to_i
    else
      col_total *= string.to_i
    end
  end
  running_total += col_total
end

puts running_total
