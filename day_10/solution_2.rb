# Solution for Day 10

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_10/input.txt")

def format_array_of_arrays(arr)
  arr.map { |inner| inner.join(",") }.join("|")
end

def find_button_by_light_index(light_index, button_arrays)
  button_arrays.each do |button|
    if button.include?(light_index)
      return button
    end
  end
  return nil
end

# def update_light_array(light_array, button)
#   new_light_array = light_array.dup
#   button.each do |light|
#     new_value = new_light_array[light] == 1 ? 0 : 1
#     new_light_array[light] = new_value
#   end
#   return new_light_array
# end

def update_joltage_array(joltage_array, button, press_count = 1)
  new_joltage_array = joltage_array.dup
  button.each do |joltage_index|
    new_joltage_array[joltage_index] -= press_count
  end
  return new_joltage_array
end

# def check_light_array(light_array)
#   light_array.each do |light|
#     if light == 1
#       return false
#     end
#   end
#   return true
# end

def check_joltage_array(joltage_array)
  joltage_array.each do |joltage|
    if joltage != 0
      return false
    end
  end
  return true
end

def validate_joltage_array(updated_joltage_array)
  updated_joltage_array.each do |joltage|
    if joltage < 0
      return false
    end
  end
  return true
end

# def check_combination_arrays(light_array, button_combination_arrays)
#   button_combination_arrays.each do |button_combo|
#     temp_light_array = light_array.dup
#     button_combo.each do |button|
#       temp_light_array = update_light_array(temp_light_array, button)
#     end
#     solved = check_light_array(temp_light_array)
#     if solved
#       return true
#     end
#   end
#   return false
# end

def get_max_presses(button, joltage_array)
  presses = 100000
  joltage_array.each_with_index do |joltage, index|
    if button.include?(index)
      presses = [presses, joltage].min
    end
  end
  return presses
end

# The output is purely an array of arrays, where each inner array represents a combination of button presses to get the target index to 0. No validating other than that.
def get_potential_press_combinations(candidate_buttons, target_index, joltage_array)
  target_joltage = joltage_array[target_index]
  num_buttons = candidate_buttons.length

  # Helper lambda to generate all combinations recursively
  generate_combinations = lambda do |remaining_sum, num_remaining, current_combination = []|
    if num_remaining == 0
      return [current_combination] if remaining_sum == 0
      return []
    end

    combinations = []
    (0..remaining_sum).each do |presses|
      new_combination = current_combination + [presses]
      combinations += generate_combinations.call(remaining_sum - presses, num_remaining - 1, new_combination)
    end
    combinations
  end

  generate_combinations.call(target_joltage, num_buttons)
end

# So this is going to find a good starting place, try the new button x times, and then do it again
# So we make a loop, and launch a ton of attempts.
# But how do we know when to stop...?
# We just do it all.
# def solve_max_first(sorted_button_array, joltage_array)
#   # puts "Current status. Joltage: #{joltage_array.join(",")} Buttons remaining: #{sorted_button_array.length}. "
#   if check_joltage_array(joltage_array)
#     return 0
#   end

#   if sorted_button_array.empty?
#     return nil
#   end

#   # binding.pry
#   # First, we check for single buttons, and solve based on those.
#   button_presses, updated_button_arrays, updated_joltage_array, valid_joltage_array = check_single_buttons(sorted_button_array, joltage_array)

#   # Return nil saying this branch doesn't work.
#   if !valid_joltage_array
#     return nil
#   end

#   minimum_presses = 100000
#   updated_button_arrays.each do |button|
#     max_presses = get_max_presses(button, updated_joltage_array)
#     # Okay, then we try to solve with the remaining...?
#     # And if we fail, then we reduce this by 1? Woof. Might take a hot second.
#     max_presses.times do |i|
#       current_presses = max_presses - i
#       new_joltage_array = update_joltage_array(updated_joltage_array.dup, button, current_presses)
#       if check_joltage_array(new_joltage_array)
#         # puts "- adding #{current_presses + button_presses} presses"
#         if current_presses < minimum_presses
#           minimum_presses = current_presses
#           break
#         end
#       end
#       new_button_array = updated_button_arrays.dup
#       new_button_array.delete(button)
#       additional_buttons = solve_max_first(new_button_array, new_joltage_array)
#       if additional_buttons.nil?
#         break
#       end
#       if additional_buttons < minimum_presses
#         minimum_presses = additional_buttons
#       end
#     end
#   end
#   return minimum_presses + button_presses
# end

# Okay, let's try a slightly better way.
# We recurisvely solve each index, sorted by the least number of buttons that affect it.
# So, for each recursive effort, we find the index with least number of buttons that affect it, and solve there.
def solve_smallest_index_first(sorted_button_array, joltage_array, presses_so_far = 0, best_so_far = nil, memo = {}, depth = 0)
  # puts "Current status. Joltage: #{joltage_array.join(",")} Buttons remaining: #{sorted_button_array.length}. Depth: #{depth} "
  # BASE CASES #
  return presses_so_far if check_joltage_array(joltage_array)
  return nil if sorted_button_array.empty?

  # Memoization key based on current state (button order normalized).
  # memo_key_buttons = sorted_button_array.map { |b| b.sort.join(",") }.sort.join(";")
  # So memo is slightly complicated. It's based on remaining joltage,
  # and will then match buttons remaining to an outcome
  memo_key = joltage_array.join(",")
  button_key = format_array_of_arrays(sorted_button_array)
  if memo.key?(memo_key)
    joltage_memo = memo[memo_key]
    if joltage_memo && joltage_memo.key?(button_key)
      cached = joltage_memo[button_key]
      return presses_so_far + cached if cached
    end

    # And if OUR answer is a subset of a longer, nil answer, then we can return nil.
    joltage_memo.keys.each do |key|
      joltage_buttons_array = key.split("|")

      # For nil responses, we care if our available buttons are a subset of the key.
      if joltage_memo[key] == nil
        if sorted_button_array.all? { |button| joltage_buttons_array.include?(button) }
          return nil
        end
      else
        # For non-nil responses, we care if the key is a subset of our available buttons.
        if joltage_buttons_array.all? { |button| sorted_button_array.include?(button) }
          # So, we should only check buttons that are NOT in the joltage_buttons_array?
          # NEXT UP - DO THIS.
        end
      end
    end

    #Okay, no exact matches. Let's now test if there is a match of a subset of buttons
    # If so, for each result, ordered by longest to shortest, search and see if it is a subset.
    # If the key is a subset of theexisting buttons, then we need only involve the given buttons.

  end

  number_of_joltages = joltage_array.length

  # Count how many buttons affect each joltage index.
  button_count_per_light = Array.new(number_of_joltages, 0)
  button_size_per_light = Array.new(number_of_joltages, 0)
  sorted_button_array.each do |button|
    button.each { |light| button_count_per_light[light] += 1 }
    button_size = button.length
    button.each do |light_index|
      if button_size_per_light[light_index] < button_size
        button_size_per_light[light_index] = button_size
      end
    end
  end

  # Choose the unsolved index influenced by the fewest buttons (tie-breaker: largest button).
  target_index = nil
  target_count = nil
  joltage_array.each_with_index do |joltage, idx|
    next if joltage <= 0
    count = button_count_per_light[idx]
    next if count == 0
    if target_count.nil? || count < target_count || (count == target_count && button_size_per_light[idx] > button_size_per_light[target_index])
      target_index = idx
      target_count = count
    end
  end

  # If there are unsolved joltages but none are covered by remaining buttons, this branch fails.
  return nil if target_index.nil?

  # Filter to buttons that affect the chosen index.
  candidate_buttons = sorted_button_array.select { |button| button.include?(target_index) }

  best_result = nil

  # if depth == 0
  #   binding.pry
  # end

  # Okay, new plan. Instead of picking a specific button, and trying all of the individual presses,
  # We instead pick every combination of button presses to get this index to 0, and do all of them,
  # and then remove ALL of those buttons (since they can't be pressed anymore, as it would go over the joltage)

  # Get an array of every possible combination of button presses in the form of an array of arrays, where the inner arrays represent which candidate_button indices we'd press each time.
  potential_press_combinations = get_potential_press_combinations(candidate_buttons, target_index, joltage_array)
  potential_press_combinations.each do |press_combination|
    new_total_presses = presses_so_far
    new_joltage_array = joltage_array.dup
    press_combination.each_with_index do |press_count, index|
      new_joltage_array = update_joltage_array(new_joltage_array, candidate_buttons[index], press_count)
      new_total_presses += press_count
    end

    #Validate it's still good
    if !validate_joltage_array(new_joltage_array)
      next
    end

    # Okay, it's good, kill all of these buttons.
    new_button_array = (sorted_button_array - candidate_buttons).dup

    # Check if we're over the already established limit.
    if best_so_far && new_total_presses >= best_so_far
      next
    end

    recursive_result = solve_smallest_index_first(
      new_button_array,
      new_joltage_array,
      new_total_presses,
      best_so_far || best_result,
      memo,
      depth + 1
    )

    next if recursive_result.nil?

    best_result = recursive_result if best_result.nil? || recursive_result < best_result
    best_so_far = best_result if best_result && (best_so_far.nil? || best_result < best_so_far)
  end

  # # Old way - try every combination of button presses for a given button, and then remove that button and try the rest.
  # candidate_buttons.each do |button|
  #   max_presses = get_max_presses(button, joltage_array)
  #   # puts " - (depth: #{depth}) Max presses for button #{button.join(",")}: #{max_presses}"
  #   if depth == 0
  #     # binding.pry
  #   end
  #   # We may have already solved an index this button relies on.
  #   # IF so, skip this button.
  #   if max_presses == 0
  #     next
  #   end

  #   # Try from the max viable presses down to 1 (pressing 0 does nothing).
  #   max_presses.downto(1) do |press_count|
  #     new_joltage_array = update_joltage_array(joltage_array.dup, button, press_count)
  #     next unless validate_joltage_array(new_joltage_array)

  #     new_total_presses = presses_so_far + press_count
  #     # Prune if we already exceed the best known solution.
  #     if best_so_far && new_total_presses >= best_so_far
  #       next
  #     end

  #     new_button_array = sorted_button_array.dup
  #     new_button_array.delete(button)

  #     recursive_result = solve_smallest_index_first(
  #       new_button_array,
  #       new_joltage_array,
  #       new_total_presses,
  #       best_so_far || best_result,
  #       memo,
  #       depth + 1
  #     )

  #     next if recursive_result.nil?

  #     best_result = recursive_result if best_result.nil? || recursive_result < best_result
  #     best_so_far = best_result if best_result && (best_so_far.nil? || best_result < best_so_far)
  #   end
  # end

  # Cache best remaining presses from this state (relative to current presses_so_far).
  if memo[memo_key]
    "Adding to memo: #{memo_key}"
    memo[memo_key][button_key] = best_result ? (best_result - presses_so_far) : nil
  else
    "Adding to memo: #{memo_key}"
    memo[memo_key] = { button_key => best_result ? (best_result - presses_so_far) : nil }
  end

  best_result
end

# def check_single_buttons(button_arrays, joltage_array)
#   button_presses = 0
#   button_press_array = []
#   updated_button_arrays = button_arrays.dup
#   updated_joltage_array = joltage_array.dup
#   number_of_joltages = joltage_array.length

#   # First, we analyze any of the joltages to see if only one button corresponds to it.
#   button_count_per_light = Array.new(number_of_joltages, 0)
#   updated_button_arrays.each do |button|
#     button.each do |light|
#       button_count_per_light[light] += 1
#     end
#   end

#   # Get a list of just the lights with one button
#   joltage_indices_with_one_button = []
#   button_count_per_light.each_with_index do |count, index|
#     if count == 1
#       joltage_indices_with_one_button << index
#     end
#   end

#   # Remove those buttons from our coming search
#   joltage_indices_with_one_button.each do |joltage_index|
#     remaining_joltage = joltage_array[joltage_index]
#     button = find_button_by_light_index(joltage_index, updated_button_arrays)
#     if !button.nil?
#       if remaining_joltage > 0
#         press_count = remaining_joltage
#         # puts "Found a single joltage: Joltage index: #{joltage_index}; button: (#{button.join(",")})"
#         button_presses += press_count
#         button_press_array << button
#         updated_joltage_array = update_joltage_array(updated_joltage_array, button, press_count)
#       end
#       updated_button_arrays.delete(button)
#     end
#   end

#   return button_  presses, updated_button_arrays, updated_joltage_array, validate_joltage_array(updated_joltage_array)
# end

def solve_line(joltage_array, button_arrays)
  #Solving the line.

  # Okay, plan here - find the ones with the most integers pressed.
  # Max those out (simultaneously), and then try to solve the rest, largest first...

  sorted_button_array = button_arrays.sort_by { |button| button.length }
  additional_presses = solve_smallest_index_first(sorted_button_array, joltage_array)

  return additional_presses
end

# Solution logic
total_button_count = 0

# lines_to_skip = [13, 86, 95, 102, 112, 121, 167, 195]
lines_to_skip = []
starting_index = 121

lines.each_with_index do |line, index|
  start_time = Time.now

  if starting_index && index < starting_index
    next
  end

  if lines_to_skip.include?(index)
    puts "Skipping line #{index}"
    next
  end

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

  # puts "Lights: #{first_segment}"
  puts "Buttons: #{second_segment}"
  puts "Third segment: #{third_segment}"

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
  third_segment_array = third_segment.strip[1..-2].split(",").map(&:to_i)

  # Solve this one.
  new_button_count = solve_line(third_segment_array, second_segment_arrays)
  elapsed_time = Time.now - start_time
  puts "SOLVED! New button count: #{new_button_count} for line #{index} (Time: #{elapsed_time.round(2)} seconds)"
  total_button_count += new_button_count
end

puts "Total button count: #{total_button_count}"
