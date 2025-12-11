# Solution for Day 11

require_relative "../utils"

# Read input lines
lines = read_input_lines("day_11/input.txt")

# Solution logic
# Rough plan:
# Import all of these as a hash.
# For each hash, calculate number of paths to out. Memo-ize.
# Straightforward.
#
def count_paths(path, paths, memo = {})
  path_outputs = paths[path]
  if path_outputs.include?("out")
    return 1
  end

  if memo[path]
    return memo[path]
  end

  total_paths = 0
  path_outputs.each do |output|
    total_paths += count_paths(output, paths, memo)
  end

  memo[path] = total_paths
  return total_paths
end

paths = {}
lines.each do |line|
  parts = line.split(":")
  entry = parts[0]
  exits = parts[1].split(" ")
  paths[entry] = exits
end

total_paths = 0

total_paths += count_paths("you", paths)

puts "Total paths: #{total_paths}"
