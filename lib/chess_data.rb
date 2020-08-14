require 'json'

class ChessPiece
  attr_reader :notation
  attr_reader :side       # White = 1, Black = 2 (cos white moves first for some reason)
  attr_accessor :position
  attr_accessor :has_moved

  def initialize(notation, side, position, has_moved = false)
    raise "Invalid datatypes!" unless notation.is_a?(String) && side.is_a?(Integer)

    @notation = notation
    @side = side
    @position = position
    @has_moved = has_moved
  end

  public

  # JSON Methods
  # Returns the JSON string of the object
  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  # Returns a new ChessPiece using information in hash
  def ChessPiece.from_hash(hash)
    return if hash.nil?

    n = hash["notation"]
    s = hash["side"]
    p = hash["position"]
    h = hash["has_moved"]

    cp = ChessPiece.new(n, s, p, h)
  end

  def debug_str
    @notation + @side.to_s
  end

  private

  def as_json(options={})
    {
      notation: @notation,
      side: @side,
      position: @position,
      has_moved: @has_moved
    }
  end
  
end

class ChessData
  attr_reader :grid         # To access correctly : @grid[y][x] / @grid[col][row]
  attr_reader :captured

  def initialize(grid = nil, captured = nil)
    if grid.nil?
      @grid = Array.new(8) { Array.new(8) {nil} }
      generate_default_grid
    else @grid = grid end

    if captured.nil? then @captured = []
    else @captured = captured end
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
      at(to).position = [-1, -1]
    end
    
    @grid[y_t][x_t] = at(from)
    at(to).has_moved = true
    at(to).position = [x_t, y_t]

    @grid[y_f][x_f] = nil
  end

  # Returns the element of grid
  def at(position)
    @grid[position[1]][position[0]]
  end

  # JSON methods
  # Returns the JSON string of the object
  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  # Returns the prettier JSON string of the object
  def to_json_pretty
    JSON.pretty_generate(self)
  end

  # Parses the JSON string into a new ChessData object
  def ChessData.from_json(json_str)
    hash = JSON.parse(json_str)
    return if hash["grid"].nil? || hash["captured"].nil?

    new_grid = Array.new(8) { Array.new(8) }
    8.times do |i|
      8.times do |j|
        new_grid[i][j] = ChessPiece.from_hash(hash["grid"][i][j])
      end
    end

    new_captured = hash["captured"].map { |x| ChessPiece.from_hash(x) }

    ChessData.new(new_grid, new_captured)
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
      @grid[1][x] = ChessPiece.new('P', 2, [-1, -1])
      @grid[6][x] = ChessPiece.new('P', 1, [-1, -1])
    end

    # Place other pieces
    2.times do |y|
      @grid[-y][0] = ChessPiece.new('R', 2 - y, [-1, -1])
      @grid[-y][1] = ChessPiece.new('N', 2 - y, [-1, -1])
      @grid[-y][2] = ChessPiece.new('B', 2 - y, [-1, -1])
      @grid[-y][3] = ChessPiece.new('Q', 2 - y, [-1, -1])
      @grid[-y][4] = ChessPiece.new('K', 2 - y, [-1, -1])
      @grid[-y][5] = ChessPiece.new('B', 2 - y, [-1, -1])
      @grid[-y][6] = ChessPiece.new('N', 2 - y, [-1, -1])
      @grid[-y][7] = ChessPiece.new('R', 2 - y, [-1, -1])
    end

    8.times do |y|
      8.times do |x|
        next if @grid[y][x].nil?

        @grid[y][x].position = [x, y]
      end
    end
  end

  def as_json(options={})
    {
      grid: @grid,
      captured: @captured
    }
  end
end