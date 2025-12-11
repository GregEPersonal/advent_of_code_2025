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
def count_paths(path, paths, visited_dac, visited_fft, memo = {})
  path_outputs = paths[path]
  if path_outputs.include?("out")
    if visited_dac && visited_fft
      return 1
    else
      return 0
    end
  end

  updated_visited_dac = visited_dac || path == "dac"
  updated_visited_fft = visited_fft || path == "fft"

  memo_string = path + updated_visited_dac.to_s + updated_visited_fft.to_s
  if memo[memo_string]
    return memo[memo_string]
  end

  total_paths = 0
  path_outputs.each do |output|
    total_paths += count_paths(output, paths, updated_visited_dac, updated_visited_fft, memo)
  end

  memo[memo_string] = total_paths
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

total_paths += count_paths("svr", paths, false, false)

puts "Total paths: #{total_paths}"
