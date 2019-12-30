# --- Day 24: It Hangs in the Balance ---
#
# It's Christmas Eve, and Santa is loading up the sleigh for this
# year's deliveries.  However, there's one small problem: he can't get
# the sleigh to balance.  If it isn't balanced, he can't defy physics,
# and nobody gets presents this year.
#
# No pressure.
#
# Santa has provided you a list of the weights of every package he
# needs to fit on the sleigh.  The packages need to be split into
# three groups of exactly the same weight, and every package has to
# fit.  The first group goes in the passenger compartment of the
# sleigh, and the second and third go in containers on either side.
# Only when all three groups weigh exactly the same amount will the
# sleigh be able to fly.  Defying physics has rules, you know!
#
# Of course, that's not the only problem.  The first group - the one
# going in the passenger compartment - needs as few packages as
# possible so that Santa has some legroom left over.  It doesn't
# matter how many packages are in either of the other two groups, so
# long as all of the groups weigh the same.
#
# Furthermore, Santa tells you, if there are multiple ways to arrange
# the packages such that the fewest possible are in the first group,
# you need to choose the way where the first group has the smallest
# quantum entanglement to reduce the chance of any "complications."
# The quantum entanglement of a group of packages is the product of
# their weights, that is, the value you get when you multiply their
# weights together.  Only consider quantum entanglement if the first
# group has the fewest possible number of packages in it and all
# groups weigh the same amount.
#
# For example, suppose you have ten packages with weights 1 through 5
# and 7 through 11.  For this situation, some of the unique first
# groups, their quantum entanglements, and a way to divide the
# remaining packages are as follows:
#
# Group 1;             Group 2; Group 3
# 11 9       (QE= 99); 10 8 2;  7 5 4 3 1
# 10 9 1     (QE= 90); 11 7 2;  8 5 4 3
# 10 8 2     (QE=160); 11 9;    7 5 4 3 1
# 10 7 3     (QE=210); 11 9;    8 5 4 2 1
# 10 5 4 1   (QE=200); 11 9;    8 7 3 2
# 10 5 3 2   (QE=300); 11 9;    8 7 4 1
# 10 4 3 2 1 (QE=240); 11 9;    8 7 5
# 9 8 3      (QE=216); 11 7 2;  10 5 4 1
# 9 7 4      (QE=252); 11 8 1;  10 5 3 2
# 9 5 4 2    (QE=360); 11 8 1;  10 7 3
# 8 7 5      (QE=280); 11 9;    10 4 3 2 1
# 8 5 4 3    (QE=480); 11 9;    10 7 2 1
# 7 5 4 3 1  (QE=420); 11 9;    10 8 2
#
# Of these, although 10 9 1 has the smallest quantum entanglement
# (90), the configuration with only two packages, 11 9, in the
# passenger compartment gives Santa the most legroom and wins.  In
# this situation, the quantum entanglement for the ideal configuration
# is therefore 99.  Had there been two configurations with only two
# packages in the first group, the one with the smaller quantum
# entanglement would be chosen.
#
# What is the quantum entanglement of the first group of packages in
# the ideal configuration?
#
# --------------------
#
# Because there are no duplicate weight values we can represent sets
# of weights using bit masks.  Given a list of masks representing all
# ways of adding up to the target amount (i.e., the total weight
# divided by 3), we must determine if a candidate mask for the
# passenger compartment, m, supports splitting the total weight into 3
# equal parts.  We do so by looking to see if, in the list, there is
# another mask, n, lying in the complement of m.  If there is, then m,
# n, and the complement of m|n all have the same weight.

Weights = open("24.in").map(&:to_i)
raise if Weights.uniq.length != Weights.length
Mask = (1<<Weights.length)-1

class Integer
  def num_set_bits
    n = self
    c = 0
    while n > 0
      c += 1 if n&1 == 1
      n >>= 1
    end
    c
  end
end

$cache = {}
def pack(w, k)
  # Returns, as a list of masks, all ways of adding up to weight w,
  # using weights from index k or greater only.
  return [0] if w == 0
  return [] if k == Weights.length
  return $cache[[w,k]] if $cache.member?([w,k])
  r = pack(w, k+1)
  if Weights[k] <= w
    r += pack(w-Weights[k], k+1).map {|m| m|(1<<k) }
  end
  $cache[[w,k]] = r
  r
end

def entanglement(mask)
  e = 1
  0.step {|i|
    break if mask == 0
    e *= Weights[i] if mask&1 == 1
    mask >>= 1
  }
  e
end

def filter3(list)
  # Filter for 3 equal groups per description above.  Expects `list`
  # to be in order of increasing number of set bits.  The expression
  # below selects the first solution and any additional solutions
  # having the same number of set bits.
  solution = nil
  list.select {|m|
    if !solution.nil? && m.num_set_bits > solution.num_set_bits
      false
    else
      mc = (~m)&Mask
      v = list.lazy.map {|x| x&mc == x }.any?
      solution = m if v && solution.nil?
      v
    end
  }
end

def solve(target, filter)
  l = pack(target, 0).sort_by {|m| m.num_set_bits }
  filter.call(l).map {|m| entanglement(m) }.min
end

puts solve(Weights.reduce(:+)/3, method(:filter3))

# --- Part Two ---
#
# That's weird... the sleigh still isn't balancing.
#
# "Ho ho ho," Santa muses to himself.  "I forgot the trunk."
#
# Balance the sleigh again, but this time, separate the packages into
# four groups instead of three.  The other constraints still apply.
#
# Given the example packages above, this would be some of the new
# unique first groups, their quantum entanglements, and one way to
# divide the remaining packages:
#
# 11 4    (QE=44); 10 5;   9 3 2 1; 8 7
# 10 5    (QE=50); 11 4;   9 3 2 1; 8 7
# 9 5 1   (QE=45); 11 4;   10 3 2;  8 7
# 9 4 2   (QE=72); 11 3 1; 10 5;    8 7
# 9 3 2 1 (QE=54); 11 4;   10 5;    8 7
# 8 7     (QE=56); 11 4;   10 5;    9 3 2 1
#
# Of these, there are three arrangements that put the minimum (two)
# number of packages in the first group: 11 4, 10 5, and 8 7.  Of
# these, 11 4 has the lowest quantum entanglement, and so it is
# selected.
#
# Now, what is the quantum entanglement of the first group of packages
# in the ideal configuration?

def filter4(list)
  solution = nil
  list.select {|m|
    if !solution.nil? && m.num_set_bits > solution.num_set_bits
      false
    else
      mc = (~m)&Mask
      v = list.lazy.map {|x|
        if x&mc == x
          mxc = (~(x|m))&Mask
          list.lazy.map {|y| y&mxc == y }.any?
        else
          false
        end
      }.any?
      solution = m if v && solution.nil?
      v
    end
  }
end

puts solve(Weights.reduce(:+)/4, method(:filter4))
