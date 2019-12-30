# --- Day 22: Wizard Simulator 20XX ---
#
# Little Henry Case decides that defeating bosses with swords and
# stuff is boring.  Now he's playing the game with a wizard.  Of
# course, he gets stuck on another boss and needs your help again.
#
# In this version, combat still proceeds with the player and the boss
# taking alternating turns.  The player still goes first.  Now,
# however, you don't get any equipment; instead, you must choose one
# of your spells to cast.  The first character at or below 0 hit
# points loses.
#
# Since you're a wizard, you don't get to wear armor, and you can't
# attack normally.  However, since you do magic damage, your
# opponent's armor is ignored, and so the boss effectively has zero
# armor as well.  As before, if armor (from a spell, in this case)
# would reduce damage below 1, it becomes 1 instead - that is, the
# boss' attacks always deal at least 1 damage.
#
# On each of your turns, you must select one of your spells to cast.
# If you cannot afford to cast any spell, you lose.  Spells cost mana;
# you start with 500 mana, but have no maximum limit.  You must have
# enough mana to cast a spell, and its cost is immediately deducted
# when you cast it.  Your spells are Magic Missile, Drain, Shield,
# Poison, and Recharge.
#
# - Magic Missile costs 53 mana.  It instantly does 4 damage.
# - Drain costs 73 mana.  It instantly does 2 damage and heals you for
#   2 hit points.
# - Shield costs 113 mana.  It starts an effect that lasts for 6
#   turns.  While it is active, your armor is increased by 7.
# - Poison costs 173 mana.  It starts an effect that lasts for 6
#   turns.  At the start of each turn while it is active, it deals the
#   boss 3 damage.
# - Recharge costs 229 mana.  It starts an effect that lasts for 5
#   turns.  At the start of each turn while it is active, it gives you
#   101 new mana.
#
# Effects all work the same way.  Effects apply at the start of both
# the player's turns and the boss' turns.  Effects are created with a
# timer (the number of turns they last); at the start of each turn,
# after they apply any effect they have, their timer is decreased by
# one.  If this decreases the timer to zero, the effect ends.  You
# cannot cast a spell that would start an effect which is already
# active.  However, effects can be started on the same turn they end.
#
# For example, suppose the player has 10 hit points and 250 mana, and
# that the boss has 13 hit points and 8 damage:
#
# -- Player turn --
# - Player has 10 hit points, 0 armor, 250 mana
# - Boss has 13 hit points
# Player casts Poison.
#
# -- Boss turn --
# - Player has 10 hit points, 0 armor, 77 mana
# - Boss has 13 hit points
# Poison deals 3 damage; its timer is now 5.
# Boss attacks for 8 damage.
#
# -- Player turn --
# - Player has 2 hit points, 0 armor, 77 mana
# - Boss has 10 hit points
# Poison deals 3 damage; its timer is now 4.
# Player casts Magic Missile, dealing 4 damage.
#
# -- Boss turn --
# - Player has 2 hit points, 0 armor, 24 mana
# - Boss has 3 hit points
# Poison deals 3 damage.  This kills the boss, and the player wins.
#
# Now, suppose the same initial conditions, except that the boss has
# 14 hit points instead:
#
# -- Player turn --
# - Player has 10 hit points, 0 armor, 250 mana
# - Boss has 14 hit points
# Player casts Recharge.
#
# -- Boss turn --
# - Player has 10 hit points, 0 armor, 21 mana
# - Boss has 14 hit points
# Recharge provides 101 mana; its timer is now 4.
# Boss attacks for 8 damage!
#
# -- Player turn --
# - Player has 2 hit points, 0 armor, 122 mana
# - Boss has 14 hit points
# Recharge provides 101 mana; its timer is now 3.
# Player casts Shield, increasing armor by 7.
#
# -- Boss turn --
# - Player has 2 hit points, 7 armor, 110 mana
# - Boss has 14 hit points
# Shield's timer is now 5.
# Recharge provides 101 mana; its timer is now 2.
# Boss attacks for 8 - 7 = 1 damage!
#
# -- Player turn --
# - Player has 1 hit point, 7 armor, 211 mana
# - Boss has 14 hit points
# Shield's timer is now 4.
# Recharge provides 101 mana; its timer is now 1.
# Player casts Drain, dealing 2 damage, and healing 2 hit points.
#
# -- Boss turn --
# - Player has 3 hit points, 7 armor, 239 mana
# - Boss has 12 hit points
# Shield's timer is now 3.
# Recharge provides 101 mana; its timer is now 0.
# Recharge wears off.
# Boss attacks for 8 - 7 = 1 damage!
#
# -- Player turn --
# - Player has 2 hit points, 7 armor, 340 mana
# - Boss has 12 hit points
# Shield's timer is now 2.
# Player casts Poison.
#
# -- Boss turn --
# - Player has 2 hit points, 7 armor, 167 mana
# - Boss has 12 hit points
# Shield's timer is now 1.
# Poison deals 3 damage; its timer is now 5.
# Boss attacks for 8 - 7 = 1 damage!
#
# -- Player turn --
# - Player has 1 hit point, 7 armor, 167 mana
# - Boss has 9 hit points
# Shield's timer is now 0.
# Shield wears off, decreasing armor by 7.
# Poison deals 3 damage; its timer is now 4.
# Player casts Magic Missile, dealing 4 damage.
#
# -- Boss turn --
# - Player has 1 hit point, 0 armor, 114 mana
# - Boss has 2 hit points
# Poison deals 3 damage.  This kills the boss, and the player wins.
#
# You start with 50 hit points and 500 mana points.  The boss's actual
# stats are in your puzzle input.  What is the least amount of mana
# you can spend and still win the fight?  (Do not include mana
# recharge effects as "spending" negative mana.)
#
# --------------------
#
# We walk the game tree depth first and propagate up the least amount
# spent that resulted in a win.  As an optimization, subtrees are
# pruned when the amount spent exceeds the best solution found so far.

$best = nil

class Spell

  attr_reader :cost

  def initialize(index, cost:, damage:nil, healing:nil, armor:nil,
    recharge:nil, duration:1)
    @index, @cost, @damage, @healing, @armor, @recharge, @duration =
      index, cost, damage, healing, armor, recharge, duration
  end

  # We distinguish between casting a spell, and applying the effects
  # of a spell to the game state over time.

  def cast(state)
    state.mana -= @cost
    state.spent += @cost
    state.timers[@index] = @duration
  end

  def apply(state)
    state.boss_points -= @damage if !@damage.nil?
    state.my_points += @healing if !@healing.nil?
    if !@armor.nil?
      state.armor = (state.timers[@index] > 1 ? @armor : 0)
    end
    state.mana += @recharge if !@recharge.nil?
    state.timers[@index] -= 1
  end

end

Spells = [
  Spell.new(0, cost:53, damage:4),                  # magic missile
  Spell.new(1, cost:73, damage:2, healing:2),       # drain
  Spell.new(2, cost:113, armor:7, duration:6),      # shield
  Spell.new(3, cost:173, damage:3, duration:6),     # poison
  Spell.new(4, cost:229, recharge:101, duration:5)] # recharge

class State

  attr_accessor :my_points, :mana, :armor, :boss_points, :boss_damage, :timers,
    :spent

  def State.start
    s = State.new
    s.my_points = 50
    s.mana = 500
    s.armor = 0
    s.boss_points, s.boss_damage = open("22.in").read.scan(/\d+/).map(&:to_i)
    s.timers = Array.new(Spells.length, 0)
    s.spent = 0
    s
  end

  def clone
    s = super
    s.timers = @timers.clone
    s
  end

  def apply_spells
    (0...Spells.length).select {|i| @timers[i] > 0 }.each do |i|
      Spells[i].apply(self)
    end
  end

  def update_best
    $best = $best.nil? ? @spent : [$best, @spent].min
  end

  def handicap # for part 2
  end

  def my_turn
    handicap
    return nil if me_dead? || (!$best.nil? && @spent >= $best)
    apply_spells
    if boss_dead?
      update_best
      return @spent
    end
    (0...Spells.length)
      .select {|i| @timers[i] == 0 && @mana >= Spells[i].cost }
      .map {|i|
        s = clone
        Spells[i].cast(s)
        s.boss_turn
      }
      .select {|r| !r.nil? }
      .min
  end

  def boss_turn
    apply_spells
    if boss_dead?
      update_best
      return @spent
    end
    @my_points -= [@boss_damage-@armor, 1].max
    return nil if me_dead?
    my_turn
  end

  def me_dead?
    @my_points <= 0
  end

  def boss_dead?
    @boss_points <= 0
  end

end

puts State.start.my_turn

# --- Part Two ---
#
# On the next run through the game, you increase the difficulty to
# hard.
#
# At the start of each player turn (before any other effects apply),
# you lose 1 hit point.  If this brings you to or below 0 hit points,
# you lose.
#
# With the same starting stats for you and the boss, what is the least
# amount of mana you can spend and still win the fight?

class State
  def handicap
    @my_points -= 1
  end
end

$best = nil
puts State.start.my_turn
