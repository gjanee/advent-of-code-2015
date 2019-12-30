# --- Day 9: All in a Single Night ---
#
# Every year, Santa manages to deliver all of his presents in a single
# night.
#
# This year, however, he has some new locations to visit; his elves
# have provided him the distances between every pair of locations.  He
# can start and end at any two (different) locations he wants, but he
# must visit each location exactly once.  What is the shortest
# distance he can travel to achieve this?
#
# For example, given the following distances:
#
# London to Dublin = 464
# London to Belfast = 518
# Dublin to Belfast = 141
#
# The possible routes are therefore:
#
# Dublin -> London -> Belfast = 982
# London -> Dublin -> Belfast = 605
# London -> Belfast -> Dublin = 659
# Dublin -> Belfast -> London = 659
# Belfast -> Dublin -> London = 605
# Belfast -> London -> Dublin = 982
#
# The shortest of these is London -> Dublin -> Belfast = 605, and so
# the answer is 605 in this example.
#
# What is the distance of the shortest route?
#
# --------------------
#
# Traveling salesman problem... fortunately there are only 8 cities,
# so only 8! = 40,320 permutations to evaluate.

require "set"

cities = Set.new
distance = {}
open("09.in").each do |l|
  m = /(.*) to (.*) = (.*)/.match(l)
  distance[[m[1],m[2]]] = distance[[m[2],m[1]]] = m[3].to_i
  cities.add(m[1])
  cities.add(m[2])
end

min, max = cities.to_a.permutation
  .map {|p| (0..p.length-2).map {|i| distance[[p[i],p[i+1]]] }.reduce(:+) }
  .minmax

puts min

# --- Part Two ---
#
# The next year, just to show off, Santa decides to take the route
# with the longest distance instead.
#
# He can still start and end at any two (different) locations he
# wants, and he still must visit each location exactly once.
#
# For example, given the distances above, the longest route would be
# 982 via (for example) Dublin -> London -> Belfast.
#
# What is the distance of the longest route?

puts max
