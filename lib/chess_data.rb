require 'json'

class ChessPiece
  attr_reader :notation
  attr_reader :side       # White = 1, Black = 2 (cos white moves first for some reason)
  attr_accessor :position
  attr_accessor :num_of_moves

  def initialize(notation, side, position)
    raise "Invalid datatypes!" unless notation.is_a?(String) && side.is_a?(Integer)

    @notation = notation
    @side = side
    @position = position
    @num_of_moves = 0
  end

  public

  def debug_str
    @notation + @side.to_s
  end
end

class ChessData
  attr_reader :grid         # To access correctly : @grid[y][x] / @grid[col][row]
  attr_reader :captured
  attr_reader :moves

  def initialize()
    @grid = Array.new(8) { Array.new(8) {nil} }
    generate_default_grid

    @moves = []
    @captured = []
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
    
    capture(at(to)) unless at(to).nil?
    
    @grid[y_t][x_t] = at(from)
    at(to).num_of_moves += 1
    at(to).position = [x_t, y_t]

    @grid[y_f][x_f] = nil

    @moves << "#{x_f}#{y_f}-#{x_t}#{y_t}"
  end

  def capture(piece)
    pos = piece.position
    @grid[pos[1]][pos[0]] = nil

    @captured << piece
    piece.position = [-1, -1]
  end

  # Returns the element of grid
  def at(position)
    @grid[position[1]][position[0]]
  end

  def move_by_str(str)
    raise "Invalid format for move string!" unless str.length == 5

    rgx_match = str.match(/^[0-9]{2}-[0-9]{2}$/)
    raise "Invalid format for move string!" if rgx_match.nil?

    from = [str[0].to_i, str[1].to_i]
    to = [str[3].to_i, str[4].to_i]
    move_piece(from, to)
  end
  
  def move_by_arr(arr)
    arr.each do |move_str|
      move_by_str(move_str)
    end
  end

  # JSON Methods
  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def ChessData.from_json(json_str)
    hash = JSON.parse(json_str)
    puts hash
    return if hash["moves"].nil?

    cd = ChessData.new
    cd.move_by_arr(hash["moves"])

    cd
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

  def as_json(options = {})
    {
      moves: @moves
    }
  end
end