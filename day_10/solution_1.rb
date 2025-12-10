# Solution for Day 10

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_10/input.txt")

def find_button_by_light_index(light_index, button_arrays)
  button_arrays.each do |button|
    if button.include?(light_index)
      return button
    end
  end
  return nil
end

def update_light_array(light_array, button)
  new_light_array = light_array.dup
  button.each do |light|
    new_value = new_light_array[light] == 1 ? 0 : 1
    new_light_array[light] = new_value
  end
  return new_light_array
end

def check_light_array(light_array)
  light_array.each do |light|
    if light == 1
      return false
    end
  end
  return true
end

def check_combination_arrays(light_array, button_combination_arrays)
  button_combination_arrays.each do |button_combo|
    temp_light_array = light_array.dup
    button_combo.each do |button|
      temp_light_array = update_light_array(temp_light_array, button)
    end
    solved = check_light_array(temp_light_array)
    if solved
      return true
    end
  end
  return false
end

# def add_buttons(current_array, button_arrays, start_index, presses_remaining)
#   if presses_remaining == 0
#     return current_array
#   end

#   presses_remaining = presses_remaining
#   button_combos = []

#   button_arrays.each_with_index do |button, index|
#     if index > start_index
#       combo = current_array.dup
#       combo += add_buttons([button], button_arrays, index, presses_remaining - 1)
#       button_combos << combo
#     end
#   end

#   return button_combos
# end

def get_combinations_for_press_count(button_arrays, new_press_count, start_index = -1, current_array = [])
  # Goal is to get each possible combination of buttons for a given press count.
  presses_remaining = new_press_count
  button_combos = []

  if presses_remaining == 0
    return [current_array]
  end

  button_arrays.each_with_index do |button, index|
    if index > start_index
      new_combo = current_array.dup
      new_combo << button
      sub_combos = get_combinations_for_press_count(button_arrays, presses_remaining - 1, index, new_combo)
      button_combos.concat(sub_combos)
    end
  end

  return button_combos
end

def solve_line(light_array, button_arrays)
  #Solving the line.
  # Brute force. Let's
  button_presses = 0
  button_press_array = []
  updated_button_arrays = button_arrays.dup
  updated_light_array = light_array.dup
  number_of_lights = light_array.length
  number_of_buttons = button_arrays.length

  # First, we analyze any of the lights to see if only one button corresponds to it.
  button_count_per_light = Array.new(number_of_lights, 0)
  button_arrays.each do |button|
    button.each do |light|
      button_count_per_light[light] += 1
    end
  end

  # Get a list of just the lights with one button
  light_indices_with_one_button = []
  button_count_per_light.each_with_index do |count, index|
    if count == 1
      light_indices_with_one_button << index
    end
  end

  # Remove those buttons from our coming search
  light_indices_with_one_button.each do |light_index|
    light_on = light_array[light_index]
    button = find_button_by_light_index(light_index, updated_button_arrays)
    if !button.nil?
      if light_on == 1
        puts "Found a single light: Light index: #{light_index}; button: (#{button.join(",")})"
        button_presses += 1
        button_press_array << button
        updated_light_array = update_light_array(updated_light_array, button)
      end
      updated_button_arrays.delete(button)
    end
  end

  # Okay, so we now have some number of button presses and some buttons chosen.
  if check_light_array(updated_light_array)
    puts "Solved without brute force"
    return button_presses
  end
  # Now we brute force the rest.

  new_press_count = 1
  while true
    # So, for this press count, get all the combinations and test them.
    puts "Attempting with #{new_press_count} buttons"
    button_combination_arrays = get_combinations_for_press_count(updated_button_arrays, new_press_count)
    solved = check_combination_arrays(updated_light_array, button_combination_arrays)
    if solved
      return button_presses + new_press_count
    end
    new_press_count += 1
  end
end

# Solution logic
total_button_count = 0

lines.each_with_index do |line, index|
  #Parse the line.
  #The first segment end where "]" is found.
  # The second segment goes from there until "{" is found.
  # The final segment goes from there until the end of the line.
  # We DO want to include the "]" and "{" in the segments.

  end_of_first_segment = line.index("]")
  start_of_third_segment = line.index("{")
  first_segment = line[0..end_of_first_segment]
  second_segment = line[end_of_first_segment + 1..start_of_third_segment - 1]
  third_segment = line[start_of_third_segment..-1]

  puts "Lights: #{first_segment}"
  puts "Buttons: #{second_segment}"
  # puts "Third segment: #{third_segment}"

  first_segment_array = []
  first_segment.strip.chars[1..-2].each do |char|
    if char == "."
      first_segment_array << 0
    else
      first_segment_array << 1
    end
  end
  second_segment_arrays = []
  second_segment.split(" ").each do |segment|
    second_segment_arrays << segment.strip[1..-2].split(",").map(&:to_i)
  end
  # Ignore third segment for now.

  # Solve this one.
  new_button_count = solve_line(first_segment_array, second_segment_arrays)
  puts "SOLVED! New button count: #{new_button_count} for line #{index}"
  total_button_count += new_button_count
end

puts "Total button count: #{total_button_count}"
