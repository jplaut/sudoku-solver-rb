#!usr/bin/env ruby

class SudokuSolver
  ROWS = ('A'..'I').to_a
  COLS = ('1'..'9').to_a
  attr_reader :rows, :cols, :squares, :unitlist, :units, :peers, :digits

  def cross(a, b)
    a.map {|x| b.map {|y| x.to_s + y.to_s}}.flatten
  end

  def initialize()
    @squares = cross(ROWS, COLS)

    @unitlist = []
    ROWS.each {|r| unitlist << cross([r], COLS)}
    COLS.each {|c| unitlist << cross(ROWS, [c])}
    ROWS.each_slice(3).each {|rp| COLS.each_slice(3).each {|cp| unitlist << cross(rp, cp)}}

    @units = {}
    squares.each do |s|
      units[s] = []
      unitlist.each {|u| units[s] << u if u.include?(s)}
    end

    @peers = {}
    squares.each do |s|
      peers[s] = []
      units[s].each {|u| u.each {|x| peers[s] << x unless s == x}}
    end
  end

  def parse_grid(grid)
    digits = '123456789'
    values = {}
    squares.each {|s| values[s] = digits}
    grid = grid.to_s.split('')
    squares.zip(grid).each do |s,d|
      return false unless assign(values, s, d) if digits.include?(d)
    end

    return values
  end

  def assign(values, s, d)
    other_values = values[s].sub(d, '')

    other_values.each_char do |d2|
      return false unless eliminate(values, s, d2)
    end

    return values
  end

  def eliminate(values, s, d)
    return values unless values[s].include?(d)  #number was already eliminated
    values[s] = values[s].sub(d, '')

    return false if values[s].length == 0   #contradiction

    if values[s].length == 1
      peers[s].each {|p| return false unless eliminate(values, p, values[s])}
    end

    units[s].each do |u|
      dsquares = []
      u.each {|s2| dsquares << s2 if values[s2].include?(d)}
      return false if dsquares.length == 0 #if there are no possible squares for number, something went wrong
      return false unless assign(values, dsquares[0], d) if dsquares.length == 1 #if there is only one possible square for a number, assign that number to that square
    end

    return values
  end

  def search(values)
    return false if values == false

    solved = true
    squares.each do |s|
      if values[s].length > 1
        solved = false
        break
      end
    end
    return values if solved == true

    min = 9
    start = ''
    squares.each do |s|
      l = values[s].length
      if l > 1 && l < min
        min = l
        start = s
      end
    end

    values[start].each_char do |s|
      solution = search(assign(values.clone, start, s))
      return solution unless solution == false
    end

    return false
  end

  def solve(grid)
    solution = search(parse_grid(grid))
    return stringify_solution(solution)
  end

  def stringify_solution(values)
    return values.values.join('')
  end
end
