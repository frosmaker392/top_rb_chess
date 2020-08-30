require 'json'

class ChessPiece
  attr_reader :notation
  attr_reader :side       # White = 1, Black = 2 (cos white moves first for some reason)
  attr_accessor :position
  attr_accessor :num_of_moves   # Records number of moves it has underwent

  def initialize(notation, side, position = [-1, -1])
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
  attr_reader :actions
  attr_reader :en_passant_vulnerable    # Denotes the piece that is vulnerable to an en-passant move
  attr_reader :pieces_by_side
  attr_reader :is_last_move_capture

  def initialize()
    @grid = Array.new(8) { Array.new(8) {nil} }

    @actions = []
    @captured = []
    @pieces_by_side = {1 => [], 2 => []}

    # Additional variables for revert
    @is_last_move_capture = false
    @en_passant_vulnerable_prev = nil

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

    @en_passant_vulnerable_prev = @en_passant_vulnerable
    @en_passant_vulnerable = nil
    if y_f == 1 && y_t == 3 || y_f == 6 && y_t == 4
      piece = at(from)
      @en_passant_vulnerable = piece if piece.notation == 'P'
    end
    
    @is_last_move_capture = !at(to).nil?
    capture(at(to), false) if @is_last_move_capture
    
    @grid[y_t][x_t] = at(from)
    at(to).num_of_moves += 1
    at(to).position = [x_t, y_t]

    @grid[y_f][x_f] = nil

    @actions << "#{x_f}#{y_f}-#{x_t}#{y_t}"
  end

  # Pushes a piece to the captured array and sets the grid element at that position
  # to nil. If explicit is true it records the capture as a move ('x[pos]')
  def capture(piece, explicit = true)
    pos = piece.position
    @grid[pos[1]][pos[0]] = nil

    @captured << piece
    piece.position = [-1, -1]

    @pieces_by_side[piece.side].delete(piece)

    @actions << "x#{pos[0]}#{pos[1]}" if explicit
  end

  # Returns the element of grid
  def at(position)
    @grid[position[1]][position[0]]
  end

  # Promotes a pawn to a queen by default, or to a desired type (other than pawn and king)
  def promote(piece, to_type = 'Q')
    raise "Intended piece is nil/not a pawn!" unless piece.notation == 'P'
    raise "Cannot promote to king or pawn!" if to_type == 'K' || to_type == 'P'

    pos = piece.position

    new_piece = ChessPiece.new(to_type, piece.side, pos)
    @grid[pos[1]][pos[0]] = new_piece

    piece.position = [-1, -1]

    @pieces_by_side[piece.side].delete(piece)
    @pieces_by_side[piece.side] << new_piece

    @actions << "p#{pos[0]}#{pos[1]}#{to_type}"
  end

  # Reverts the last move and undoes the last capture or promotion after it
  def revert
    last_action = @actions.pop
    return if last_action.nil?

    # If last action is a capture, then place that captured piece back
    if !last_action.match(/^x[0-7]{2}$/).nil?
      captured_piece = @captured.pop
      pos = [last_action[1].to_i, last_action[2].to_i]

      @pieces_by_side[captured_piece.side] << captured_piece
      place(captured_piece, pos)

      last_action = @actions.pop            # Set the last action to the move before
      
    # If last action is a promotion, then reverse it
    elsif !last_action.match(/^p[0-7]{2}[NBRQ]$/).nil?
      pos = [last_action[1].to_i, last_action[2].to_i]
      pawn_before = ChessPiece.new('P', at(pos).side, pos)

      @pieces_by_side[pawn_before.side].delete(at(pos))
      @pieces_by_side[pawn_before.side] << pawn_before

      @grid[pos[1]][pos[0]] = pawn_before

      last_action = @actions.pop            # Set the last action to the move before
    end

    # Assuming the last action is a move, move the piece back to the position before
    from = [last_action[3].to_i, last_action[4].to_i]
    to = [last_action[0].to_i, last_action[1].to_i]

    at(from).position = to
    @grid[to[1]][to[0]] = at(from)
    @grid[from[1]][from[0]] = nil

    # Place the piece back if the last move is a capture
    if @is_last_move_capture
      captured_piece = @captured.pop

      @pieces_by_side[captured_piece.side] << captured_piece
      place(captured_piece, from)

      @is_last_move_capture = false
    end

    # Update en_passant_vulnerable to the previous value
    @en_passant_vulnerable = @en_passant_vulnerable_prev
    @en_passant_vulnerable_prev = nil
  end

  # Executes an action from a string of format (for moves) "[x_from][y_from]-[x_to][y_to]"
  # or of the format (for captures) "x[x][y]"
  # or of the format (for promotions) "p[x][y][new_notation]"
  def action_from_str(str)
    # rgx_matches[i], 0 - from-to-move, 1 - capture, 2 - promotion
    rgx_matches = [str.match(/^[0-7]{2}-[0-7]{2}$/), str.match(/^x[0-7]{2}$/), str.match(/^p[0-7]{2}[NBRQ]$/)]

    i = 0
    while rgx_matches[i].nil? && i < 3 
      i += 1
    end

    case i
    when 0
      str = rgx_matches[i][0]
      from = [str[0].to_i, str[1].to_i]
      to = [str[3].to_i, str[4].to_i]

      move_piece(from, to)
    when 1
      str = rgx_matches[i][0]
      pos = [str[1].to_i, str[2].to_i]

      capture(at(pos))
    when 2
      str = rgx_matches[i][0]
      pos = [str[1].to_i, str[2].to_i]
      to_type = str[3]

      promote(at(pos), to_type)
    else
      raise "Invalid format for move string!"
    end
  end
  
  def actions_from_arr(arr)
    arr.each { |move_str| action_from_str(move_str) }
  end

  # JSON Methods
  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def ChessData.from_json(json_str)
    hash = JSON.parse(json_str)
    return if hash["actions"].nil?

    cd = ChessData.new
    cd.actions_from_arr(hash["actions"])

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

  # Places a chess piece at position
  def place(piece, position)
    return unless at(position).nil?

    piece.position = position
    @grid[position[1]][position[0]] = piece

    @pieces_by_side[piece.side] << piece
  end

  def as_json(options = {})
    {
      actions: @actions
    }
  end
end