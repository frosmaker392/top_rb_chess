require './lib/chess_data.rb'

class ChessMoves
  attr_reader :data
  attr_reader :possible_moves

  def initialize(chess_data)
    @data = chess_data
    @possible_moves = Hash.new([])
    @possible_moves[nil] = nil

    @offsets_knight = mirror_to_all_quadrants([[1, 2], [2, 1]])
    @offsets_bishop = mirror_to_all_quadrants([[1, 1]])
    @offsets_rook = mirror_to_all_quadrants([[0, 1], [1, 0]])
    @offsets_queen = mirror_to_all_quadrants([[0, 1], [1, 0], [1, 1]])
  end

  public

  def possible_moves_at(position)
    @possible_moves[@data.at(position)]
  end

  def evaluate_moves
    8.times do |y|
      8.times do |x|
        piece = data.grid[y][x]
        next if piece.nil?

        case piece.notation
        when 'P'
          @possible_moves[piece] = eval_pawn(piece)
        when 'N'
          @possible_moves[piece] = eval_knight(piece)
        when 'B'
          @possible_moves[piece] = eval_bishop(piece)
        when 'R'
          @possible_moves[piece] = eval_rook(piece)
        when 'Q'
          @possible_moves[piece] = eval_queen(piece)
        when 'K'
          @possible_moves[piece] = eval_king(piece)
        else
          raise "Invalid piece detected!"
        end
      end
    end

    @data.captured.each do |c_piece|
      @possible_moves[c_piece] = nil
    end
  end

  private

  # Individual evaluation methods for each piece type
  # Each returns an array of possible moves
  def eval_pawn(piece)
    pos = piece.position
    out = []

    max_step = piece.num_of_moves == 0 ? 2 : 1
    offset = piece.side == 2 ? 1 : -1
    
    max_step.times do |i|
      p = [pos[0], pos[1] + offset * (i + 1)]

      break unless is_within_board?(p) && @data.at(p).nil?
      out << p
    end

    # Evaluation for a possible diagonal-adjacent capture of the pawn
    # fda - front-diagonal-adjacent (sorry i don't know a more concise term for that)
    fda_pos = [[pos[0] + 1, pos[1] + offset], [pos[0] - 1, pos[1] + offset]]

    fda_pos.each do |p|
      next unless is_within_board?(p) && !@data.at(p).nil?
      next if @data.at(p).side == piece.side

      out << p
    end

    out
  end

  def eval_knight(piece)
    pos = piece.position
    out = []
    
    @offsets_knight.each do |offset|
      target_pos = [pos[0] + offset[0], pos[1] + offset[1]]
      next unless is_within_board?(target_pos)

      out << target_pos if can_move_to?(target_pos, piece.side)
    end

    out
  end

  def eval_bishop(piece)
    out = []

    @offsets_bishop.each do |offset|
      out += eval_traversal_from_by(piece, offset)
    end

    out
  end

  def eval_rook(piece)
    out = []

    @offsets_rook.each do |offset|
      out += eval_traversal_from_by(piece, offset)
    end

    out
  end

  def eval_queen(piece)
    out = []

    @offsets_queen.each do |offset|
      out += eval_traversal_from_by(piece, offset)
    end

    out
  end

  def eval_king(piece)
    pos = piece.position
    out = []
    
    @offsets_queen.each do |offset|
      target_pos = [pos[0] + offset[0], pos[1] + offset[1]]
      next unless is_within_board?(target_pos)

      out << target_pos if can_move_to?(target_pos, piece.side)
    end

    out
  end

  # Traverses from piece by offset, pushing the position it's at into an array
  # until the position cannot be moved to (can_move_to becomes false) or
  # the position before is occupied.
  # Returns the array of positions it traversed
  def eval_traversal_from_by(piece, offset)
    out = []
    pos_current = [piece.position[0] + offset[0], piece.position[1] + offset[1]]
    pos_before = nil

    while can_move_to?(pos_current, piece.side)
      out << pos_current

      pos_before = pos_current
      pos_current = [pos_current[0] + offset[0], pos_current[1] + offset[1]]

      break unless @data.at(pos_before).nil?
    end

    out
  end

  # Mirrors all positions in the array to all quadrants,
  # e.g : [[1, 1]] => [[1, 1], [-1, 1], [1, -1], [-1, -1]].
  # Returns all the mirrored coordinates plus the original coordinates in an array
  def mirror_to_all_quadrants(pos_arr)
    set = pos_arr.to_set
    pos_arr.each do |pos|
      set.add([-pos[0], pos[1]])
      set.add([pos[0], -pos[1]])
      set.add([-pos[0], -pos[1]])
    end

    set.to_a
  end

  # Is the position empty/Does it have an enemy piece? (for all pieces other than pawn)
  def can_move_to?(position, piece_side)
    return false unless is_within_board?(position)
    return true if @data.at(position).nil?
    return true unless @data.at(position).side == piece_side
    false
  end

  # Returns true if position is within bounds of the grid
  def is_within_board?(position)
    position[0] > -1 && position[0] < 8 && position[1] > -1 && position[1] < 8
  end
end