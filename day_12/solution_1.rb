# Solution for Day 12

require_relative "../utils"
require "pry"

# Read input lines
lines = read_input_lines("day_12/input.txt")

# Solution logic

presents_array = []
presents_length_array = []
puzzle_array = []
on_puzzle_stage_index = 0

lines.each_with_index do |line, index|
  if line.include?("x")
    on_puzzle_stage_index = index
    break
  end
end

# Slice by groups up 5 lines, up until the puzzle stage.
lines[0..on_puzzle_stage_index - 1].each_slice(5) do |slice|
  present_index = slice[0][0].to_i
  present_array = slice[1..3]
  new_present_array = present_array.map { |row| row.split("") }
  presents_array[present_index] = new_present_array

  place_count = 0
  present_array.each_with_index do |row, row_index|
    row.chars.each do |cell|
      if cell == "#"
        place_count += 1
      end
    end
  end
  presents_length_array[present_index] = place_count
end

# Handle lines, creating puzzles for each.
lines[on_puzzle_stage_index..-1].each do |puzzle|
  line_parts = puzzle.split(":")
  width, height = line_parts[0].split("x").map(&:to_i)
  puzzle_requirements = line_parts[1].strip.split(" ").map(&:to_i)

  puzzle_array << { width: width, height: height, requirements: puzzle_requirements }
end

puts presents_array.length
puts puzzle_array.length

presents_array_plus_rotations = Array.new(presents_array.length) { Array.new(4) }
presents_array.each_with_index do |present, present_index|
  presents_array_plus_rotations[present_index][0] = present
  presents_array_plus_rotations[present_index][1] = present.reverse.transpose
  presents_array_plus_rotations[present_index][2] = presents_array_plus_rotations[present_index][1].reverse.transpose
  presents_array_plus_rotations[present_index][3] = presents_array_plus_rotations[present_index][2].reverse.transpose
end

def print_puzzle_board(puzzle_board)
  puzzle_board.each do |row|
    puts row.join("")
  end
  puts "--------------------------------"
end

#Okay, so potential strategies:
# Add puzzles 1x1 to see how well we can fit them in.
# Add puzzle "chunks" in that we know fit well
# Potential Chunks:
# X . .    # # .   # # #    3 x 6
# X X .    . # #   . # #
# X X X    . . #   . # #
#
# # # #
# # . .    # # #      Not perfect.
# # # #    . . #
# . . .    # # #

# First, let's try adding these one by one.
# Given a puzzle, find the index closest to 0,0 that we can add to.
# Add the best one, based on filling the most space close to 0,0,
# with a preference for the one with the most pieces left.

def next_index(puzzle_board, puzzle_attempts, last_index)
  # Find the index closest to 0,0 that we can add to.
  # So, that is the closest index to 0,0 that IS a dot, and that we haven't tried and failed to add to.
  # Let's just diagonal walk, 0,0, then 1,0, then 0,1, then 2,0, then 1,1, then 0,2, then 3,0, then 2,1, then 1,2, then 0,3, etc.
  total_coords = last_index[0] + last_index[1]
  next_index = last_index
  loop do
    if puzzle_board[next_index[1]][next_index[0]] == "." && !puzzle_attempts.include?(next_index)
      return next_index
    end
    # To get next coordinate, we will subtract one from x, and add one to y, unless x is 0, in which case we will add 1 to total coords, and start over with x = total coords and y = 0
    if next_index[0] == 0 || next_index[1] == puzzle_board.length - 1
      total_coords += 1
      if total_coords > puzzle_board[0].length - 1
        diff = total_coords - puzzle_board[0].length
        next_index = [total_coords - diff, diff]
      else
        next_index = [total_coords, 0]
      end
    else
      next_index = [next_index[0] - 1, next_index[1] + 1]
    end
    if total_coords > puzzle_board.length - 1 + puzzle_board[0].length - 1
      return nil
    end
  end
  return nil
end

def score_puzzle(next_index, puzzle_board, oriented_present, spot_index)
  # Okay, so we basically try this one out and see if it fits.
  # If it does, we score it based on how much space it fills.
  # If it doesn't, we return -1.
  # The spots are:
  # 0,0 - 0,1 - 0,2
  # 1,0 - 1,1 - 1,2
  # 2,0 - 2,1 - 2,2
  # Which correspond to spot_indices of
  # 0 - 1 - 2
  # 3 - 4 - 5
  # 6 - 7 - 8
  max_score = puzzle_board.length + puzzle_board[0].length
  lookup_table = {
    0 => [0, 0],
    1 => [0, 1],
    2 => [0, 2],
    3 => [1, 0],
    4 => [1, 1],
    5 => [1, 2],
    6 => [2, 0],
    7 => [2, 1],
    8 => [2, 2],
  }

  start_index_offset = lookup_table[spot_index]
  start_index = [next_index[0] - start_index_offset[0], next_index[1] - start_index_offset[1]]
  end_index = [start_index[0] + oriented_present.length - 1, start_index[1] + oriented_present[0].length - 1]

  if start_index[0] < 0 || start_index[1] < 0 || end_index[0] >= puzzle_board[0].length || end_index[1] >= puzzle_board.length
    return -1
  end

  # Confirm we can fit the puzzle in this spot.
  (0..8).each do |i|
    new_spot_index = [start_index[0] + lookup_table[i][0], start_index[1] + lookup_table[i][1]]
    if puzzle_board[new_spot_index[1]][new_spot_index[0]] != "." && oriented_present[lookup_table[i][1]][lookup_table[i][0]] != "."
      return -1
    end
  end

  # Lastly, get a score for this spot.
  # For each '#' in this piece, add max_score - (x + y) to our total score.
  score = 0
  (0..8).each do |i|
    lookup_index = lookup_table[i]
    new_spot_index = [start_index[0] + lookup_index[0], start_index[1] + lookup_index[1]]
    if oriented_present[lookup_index[1]][lookup_index[0]] != "."
      score += max_score - (new_spot_index[0] + new_spot_index[1])
    end
  end
  return score
end

def add_puzzle_to_board(next_index, puzzle_board, best_present, spot_index)
  lookup_table = {
    0 => [0, 0],
    1 => [0, 1],
    2 => [0, 2],
    3 => [1, 0],
    4 => [1, 1],
    5 => [1, 2],
    6 => [2, 0],
    7 => [2, 1],
    8 => [2, 2],
  }
  start_index_offset = lookup_table[spot_index]
  start_index = [next_index[0] - start_index_offset[0], next_index[1] - start_index_offset[1]]

  # Pick any alphanumeric character that is not a dot.
  random_character = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a - ["."]
  random_character = random_character.sample(1)[0]

  (0..8).each do |i|
    lookup_index = lookup_table[i]
    new_spot_index = [start_index[0] + lookup_index[0], start_index[1] + lookup_index[1]]
    if best_present[lookup_index[1]][lookup_index[0]] != "."
      puzzle_board[new_spot_index[1]][new_spot_index[0]] = random_character
    end
  end
  return puzzle_board
end

def add_puzzle(next_index, puzzle_board, presents_array_plus_rotations, requirements)
  # Okay, for this space, we are going to try every available present, in every possible orientation, and score it.
  # So that would be 9 possible spots * 4 orientations * 6 presents = 216 total tries.
  best_score = 0
  best_present_index = nil
  best_orientation = nil
  best_spot_index = nil
  # puts requirements.inspect if next_index == [0, 3]
  presents_array_plus_rotations.each_with_index do |present_rotations_array, present_index|
    if requirements[present_index] > 0
      present_rotations_array.each_with_index do |oriented_present, orientation_index|
        (0..8).each do |i| # For each of the 9 possible spots, score the puzzle.
          score = score_puzzle(next_index, puzzle_board, oriented_present, i)
          # puts "Trying:" if next_index == [0, 3]
          # print_puzzle_board(oriented_present) if next_index == [0, 3]
          # puts "Score: #{score} for present #{present_index}, orientation #{orientation_index}, spot #{i}" if next_index == [0, 3]
          if score > best_score
            best_score = score
            best_present_index = present_index
            best_orientation = orientation_index
            best_spot_index = i
          elsif score == best_score
            if requirements[present_index] > requirements[best_present_index]
              best_present_index = present_index
              best_orientation = orientation_index
              best_spot_index = i
            end
          end
        end
      end
    end
  end

  if best_present_index.nil?
    return false, puzzle_board, nil
  else
    puzzle_board = add_puzzle_to_board(next_index, puzzle_board, presents_array_plus_rotations[best_present_index][best_orientation], best_spot_index)
    return true, puzzle_board, best_present_index
  end
end

success_count = 0

puzzle_array.each_with_index do |puzzle, puzzle_index|
  requirements = puzzle[:requirements]
  puzzle_board = Array.new(puzzle[:width]) { Array.new(puzzle[:height], ".") }

  # Check that we have enough space for the puzzle.
  puzzle_spots_needed = 0
  requirements.each_with_index do |requirement, index|
    puzzle_spots_needed += requirement * presents_length_array[index]
  end
  if puzzle_spots_needed > puzzle[:width] * puzzle[:height]
    puts "Not enough space to add puzzle #{puzzle_index}. #{puzzle_spots_needed} spots needed, #{puzzle[:width] * puzzle[:height]} spots available. Skipping."
    next
  else
    puts "Enough space to add puzzle #{puzzle_index}. #{puzzle_spots_needed} spots needed, #{puzzle[:width] * puzzle[:height]} spots available. Working on puzzle."
  end

  puzzle_attempts = []
  pieces_added = 0
  next_index = [0, 0]
  while requirements.sum > 0
    next_index = next_index(puzzle_board, puzzle_attempts, next_index)
    # puts "Next index: #{next_index}"
    if next_index.nil?
      puts "No more indices to try. Failed to add all pieces for puzzle #{puzzle_index}. "
      break
    else
      success, new_puzzle_board, piece_index = add_puzzle(next_index, puzzle_board, presents_array_plus_rotations, requirements)
      # puts "Success: #{success}"
      # print_puzzle_board(new_puzzle_board) if success
      if !success
        # binding.pry
        puzzle_attempts << next_index
      else
        puzzle_board = new_puzzle_board
        pieces_added += 1
        requirements[piece_index] -= 1
      end
    end
  end
  if requirements.sum == 0
    puts "Successfully added all pieces for puzzle #{puzzle_index}. #{pieces_added} pieces added."
    print_puzzle_board(puzzle_board)
    success_count += 1
  else
    puts "Failed to add all pieces for puzzle #{puzzle_index}. "
    print_puzzle_board(puzzle_board)
  end
end

puts "Successfully solved #{success_count} puzzles."
