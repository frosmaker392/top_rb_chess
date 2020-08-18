require './lib/chess_data.rb'

class ChessMoves
  attr_reader :data
  attr_reader :possible_moves

  def initialize(chess_data)
    @data = chess_data
    @possible_moves = Hash.new([])
    @possible_moves[nil] = nil
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

    offset = piece.side == 2 ? 1 : -1
    p1 = [pos[0], pos[1] + offset]
    out << p1 if is_within_board?(p1) && @data.at(p1).nil?

    # Can move forward two positions if pawn hasn't moved
    if piece.num_of_moves == 0
      p2 = [pos[0], pos[1] + offset * 2]
      out << p2 if @data.at(p2).nil?
    end

    # When an enemy piece is at the front-right/left of the pawn
    # (right as in relative to the board)
    fr = [pos[0] + 1, pos[1] + offset]
    fl = [pos[0] - 1, pos[1] + offset]

    if is_within_board?(fr) && !@data.at(fr).nil?
      if @data.at(fr).side != piece.side
        out << fr
      end
    end

    if is_within_board?(fl) && !@data.at(fl).nil?
      if @data.at(fl).side != piece.side
        out << fl
      end
    end

    out
  end

  def eval_knight(piece)
    []
  end

  def eval_bishop(piece)
    []
  end

  def eval_rook(piece)
    []
  end

  def eval_queen(piece)
    []
  end

  def eval_king(piece)
    []
  end

  # Returns true if position is within bounds of the grid
  def is_within_board?(position)
    position[0] > -1 && position[0] < 8 && position[1] > -1 && position[1] < 8
  end
end