require 'json'

class ChessPiece
  attr_reader :notation
  attr_reader :side       # White = 1, Black = 2 (cos white moves first for some reason)
  attr_accessor :position
  attr_accessor :num_of_moves   # Records number of moves it has underwent

  def initialize(notation, side, position = [-1, -1])
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
  attr_reader :en_passant_vulnerable    # Denotes the piece that is vulnerable to an en-passant move
  attr_reader :pieces_by_side

  def initialize()
    @grid = Array.new(8) { Array.new(8) {nil} }

    @moves = []
    @captured = []
    @pieces_by_side = {1 => [], 2 => []}

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

    @en_passant_vulnerable = nil
    if y_f == 1 && y_t == 3 || y_f == 6 && y_t == 4
      piece = at(from)
      @en_passant_vulnerable = piece if piece.notation == 'P'
    end
    
    capture(at(to), false) unless at(to).nil?
    
    @grid[y_t][x_t] = at(from)
    at(to).num_of_moves += 1
    at(to).position = [x_t, y_t]

    @grid[y_f][x_f] = nil

    @moves << "#{x_f}#{y_f}-#{x_t}#{y_t}"
  end

  # Places a chess piece at position
  def place(piece, position)
    return unless at(position).nil?

    piece.position = position
    @grid[position[1]][position[0]] = piece

    @pieces_by_side[piece.side] << piece
  end

  # Pushes a piece to the captured array and sets the grid element at that position
  # to nil. If explicit is true it records the capture as a move ('x[pos]')
  def capture(piece, explicit = true)
    pos = piece.position
    @grid[pos[1]][pos[0]] = nil

    @captured << piece
    piece.position = [-1, -1]

    @moves << "x#{pos[0]}#{pos[1]}" if explicit

    @pieces_by_side[piece.side].delete(piece)
  end

  # Returns the element of grid
  def at(position)
    @grid[position[1]][position[0]]
  end

  # Executes a move according to str with format "[x_from][y_from]-[x_to][y_to]"
  def move_by_str(str)
    rgx_match_move = str.match(/^[0-7]{2}-[0-7]{2}$/)
    rgx_match_cap = str.match(/^x[0-7]{2}$/)
    raise "Invalid format for move string!" if rgx_match_move.nil? && rgx_match_cap.nil?

    unless rgx_match_move.nil?
      from = [str[0].to_i, str[1].to_i]
      to = [str[3].to_i, str[4].to_i]
      move_piece(from, to)
    else
      pos = [str[1].to_i, str[2].to_i]
      capture(at(pos))
    end
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
      place(ChessPiece.new('P', 2), [x, 1])
      place(ChessPiece.new('P', 1), [x, 6])
    end

    # Place other pieces
    2.times do |y|
      y_grid = (y == 1 ? 7 : 0)

      place(ChessPiece.new('R', 2 - y), [0, y_grid])
      place(ChessPiece.new('N', 2 - y), [1, y_grid])
      place(ChessPiece.new('B', 2 - y), [2, y_grid])
      place(ChessPiece.new('Q', 2 - y), [3, y_grid])
      place(ChessPiece.new('K', 2 - y), [4, y_grid])
      place(ChessPiece.new('B', 2 - y), [5, y_grid])
      place(ChessPiece.new('N', 2 - y), [6, y_grid])
      place(ChessPiece.new('R', 2 - y), [7, y_grid])
    end
  end

  def as_json(options = {})
    {
      moves: @moves
    }
  end
end