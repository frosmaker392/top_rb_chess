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
    []
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
end