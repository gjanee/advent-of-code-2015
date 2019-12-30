# --- Day 17: No Such Thing as Too Much ---
#
# The elves bought too much eggnog again - 150 liters this time.  To
# fit it all into your refrigerator, you'll need to move it into
# smaller containers.  You take an inventory of the capacities of the
# available containers.
#
# For example, suppose you have containers of size 20, 15, 10, 5, and
# 5 liters.  If you need to store 25 liters, there are four ways to do
# it:
#
# - 15 and 10
# - 20 and 5 (the first 5)
# - 20 and 5 (the second 5)
# - 15, 5, and 5
#
# Filling all containers entirely, how many different combinations of
# containers can exactly fit all 150 liters of eggnog?

$containers = open("17.in").map(&:to_i)

$cache = {}
def pack(v, k)
  # Returns a hash mapping number of containers to the number of ways
  # of storing volume v using that many containers from index k or
  # greater only.
  return { 0 => 1 } if v == 0
  return {} if k == $containers.length
  return $cache[[v,k]] if $cache.member?([v,k])
  r = pack(v, k+1).clone
  if $containers[k] <= v
    pack(v-$containers[k], k+1).map {|nc,nw|
      r[nc+1] = r.fetch(nc+1, 0) + nw
    }
  end
  $cache[[v,k]] = r
  r
end

r = pack(150, 0)
puts r.values.reduce(:+)

# --- Part Two ---
#
# While playing with all the containers in the kitchen, another load
# of eggnog arrives!  The shipping and receiving department is
# requesting as many containers as you can spare.
#
# Find the minimum number of containers that can exactly fit all 150
# liters of eggnog.  How many different ways can you fill that number
# of containers and still hold exactly 150 liters?
#
# In the example above, the minimum number of containers was two.
# There were three ways to use that many containers, and so the answer
# there would be 3.

puts r[r.keys.min]
