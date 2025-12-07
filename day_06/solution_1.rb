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

running_total = 0

new_lines[0].length.times do |col_index|
  operator = new_lines[new_lines.length - 1][col_index]

  col_total = operator == "+" ? 0 : 1
  new_lines.length.times do |row_index|
    if row_index == new_lines.length - 1
      next
    end
    if operator == "+"
      # puts "Adding #{new_lines[row_index][col_index].to_i} to #{col_total}"
      col_total += new_lines[row_index][col_index].to_i
    else
      # puts "Multiplying #{new_lines[row_index][col_index].to_i} to #{col_total}"
      col_total *= new_lines[row_index][col_index].to_i
    end
  end
  running_total += col_total
  # puts "Column #{col_index} total: #{col_total}"
end

puts running_total
