# --- Day 20: Infinite Elves and Infinite Houses ---
#
# To keep the Elves busy, Santa has them deliver some presents by
# hand, door-to-door.  He sends them down a street with infinite
# houses numbered sequentially: 1, 2, 3, 4, 5, and so on.
#
# Each Elf is assigned a number, too, and delivers presents to houses
# based on that number:
#
# - The first Elf (number 1) delivers presents to every house: 1, 2,
#   3, 4, 5, ....
# - The second Elf (number 2) delivers presents to every second house:
#   2, 4, 6, 8, 10, ....
# - Elf number 3 delivers presents to every third house: 3, 6, 9, 12,
#   15, ....
#
# There are infinitely many Elves, numbered starting with 1.  Each Elf
# delivers presents equal to ten times his or her number at each
# house.
#
# So, the first nine houses on the street end up like this:
#
# House 1 got 10 presents.
# House 2 got 30 presents.
# House 3 got 40 presents.
# House 4 got 70 presents.
# House 5 got 60 presents.
# House 6 got 120 presents.
# House 7 got 80 presents.
# House 8 got 150 presents.
# House 9 got 130 presents.
#
# The first house gets 10 presents: it is visited only by Elf 1, which
# delivers 1 * 10 = 10 presents.  The fourth house gets 70 presents,
# because it is visited by Elves 1, 2, and 4, for a total of 10 + 20 +
# 40 = 70 presents.
#
# What is the lowest house number of the house to get at least as many
# presents as the number in your puzzle input?
#
# --------------------
#
# The divisor sum of an integer of the form n = p^e, p prime, is
# sigma(n) = (p^(e+1)-1)/(p-1).  If m and n are coprime, then the
# divisor sum is multiplicative: sigma(m*n) = sigma(m)*sigma(n).

Input = 34000000

$cache = { 1 => 1 }
$primes = []
def divisor_sum(n)
  # must be called in order of increasing n
  return $cache[n] if $cache.member?(n)
  r = nil
  limit = Math.sqrt(n).ceil
  $primes.each do |p|
    break if p >= limit
    e = 0
    m = n
    while m%p == 0
      m /= p
      e += 1
    end
    if e > 0
      r = (p**(e+1)-1)/(p-1)*divisor_sum(m)
      break
    end
  end
  if r.nil? # n is prime
    $primes << n
    r = n+1
  end
  $cache[n] = r
  r
end

1.step do |n|
  if divisor_sum(n)*10 >= Input
    puts n
    break
  end
end

# --- Part Two ---
#
# The Elves decide they don't want to visit an infinite number of
# houses.  Instead, each Elf will stop after delivering presents to 50
# houses.  To make up for it, they decide to deliver presents equal to
# eleven times their number at each house.
#
# With these changes, what is the new lowest house number of the house
# to get at least as many presents as the number in your puzzle input?
#
# --------------------
#
# This is a substantially different problem.

size = Input/10 # estimated table size needed
a = Array.new(size, 0)
(1...size).each do |n|
  n.step(by:n, to:50*n).each do |i|
    break if i >= size
    a[i] += n*11
  end
end
puts a.index {|v| v >= Input }
