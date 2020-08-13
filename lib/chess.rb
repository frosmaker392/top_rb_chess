require 'json'

class ChessPiece
  attr_reader :notation
  attr_reader :side       # White = 1, Black = 2 (cos white moves first for some reason)
  attr_reader :has_moved

  def initialize(notation, side)
    raise "Invalid datatypes!" unless notation.is_a?(String) && side.is_a?(Integer)

    @notation = notation
    @side = side
    @has_moved = false
  end

  public

  def as_json(options={})
    {
      notation: @notation,
      side: @side,
      has_moved: @has_moved
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def debug_str
    @notation + @side.to_s
  end
end

class ChessData
  attr_reader :grid         # To access correctly : @grid[y][x] / @grid[col][row]
  attr_reader :captured

  def initialize
    @grid = Array.new(8) { Array.new(8) {nil} }
    @captured = []

    generate_default_grid
  end

  public

  # Moves a chess piece to another point without rules, ignores if out of grid 
  # or there is nothing on the 'from' position
  def move_piece(from, to)
    x_f = from[0]
    y_f = from[1]
    x_t = to[0]
    y_t = to[1]

    return if x_f > 7 || x_f < 0 || y_f > 7 || y_f < 0
    return if x_t > 7 || x_t < 0 || y_t > 7 || y_t < 0
    return if at(from).nil?
    
    unless at(to).nil?
      @captured << at(to)
    end
    @grid[y_t][x_t] = at(from)
    @grid[y_f][x_f] = nil
  end

  # Returns the element of gri
  def at(position)
    @grid[position[1]][position[0]]
  end

  def as_json(options={})
    {
      grid: @grid,
      captured: @captured
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def debug_str
    out = ""

    8.times do |y|
      8.times do |x|
        out << (at([x, y]).nil? ? '  ' : at([x, y]).debug_str)
      end
      out << "\n"
    end

    out
  end

  private

  def generate_default_grid
    # Place pawns at 2nd and 7th row
    8.times do |x|
      @grid[1][x] = ChessPiece.new('P', 2)
      @grid[6][x] = ChessPiece.new('P', 1)
    end

    # Place other pieces
    2.times do |y|
      @grid[-y][0] = ChessPiece.new('R', 2 - y)
      @grid[-y][1] = ChessPiece.new('N', 2 - y)
      @grid[-y][2] = ChessPiece.new('B', 2 - y)
      @grid[-y][3] = ChessPiece.new('Q', 2 - y)
      @grid[-y][4] = ChessPiece.new('K', 2 - y)
      @grid[-y][5] = ChessPiece.new('B', 2 - y)
      @grid[-y][6] = ChessPiece.new('N', 2 - y)
      @grid[-y][7] = ChessPiece.new('R', 2 - y)
    end
  end
end

cd = ChessData.new
puts cd.to_json