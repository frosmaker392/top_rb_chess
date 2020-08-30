require './lib/chess_moves.rb'
require './lib/error_messages.rb'

IntendedMove = Struct.new(:notation, :target_pos, :board_pos, :search_pos)

class Chess
  include ChessErrorMessages

  attr_reader :chess_data
  attr_reader :chess_moves

  def initialize(chess_data)
    @chess_data = chess_data
    @chess_moves = ChessMoves.new(chess_data)

    @current_side = 1
  end

  public

  def try_move(alg_string)
    intended_move = parse_algebra(alg_string)
    search_pos = intended_move.search_pos

    valid_pieces = []
    found_piece_type = false
    @chess_data.pieces_by_side[@current_side].each do |piece|
      next unless piece.notation == intended_move.notation

      found_piece_type = true
      
      next unless @chess_moves.possible_moves[piece].include?(intended_move.target_pos)
      
      pos = piece.position
      if search_pos[0] > 0 then next unless pos[0] == search_pos[0] end
      if search_pos[1] > 0 then next unless pos[1] == search_pos[1] end

      valid_pieces << piece
    end

    raise err_no_piece_found(intended_move.notation, @current_side) unless found_piece_type
    raise err_cannot_move(intended_move.notation, intended_move.board_pos) if valid_pieces == []
    raise err_more_pieces_can_move(valid_pieces.count, intended_move.notation, intended_move.board_pos) if valid_pieces.length > 1

    en_passant_vulnerable = @chess_data.en_passant_vulnerable
    pos_before = valid_pieces[0].position

    @chess_data.move_piece(valid_pieces[0].position, intended_move.target_pos)

    if intended_move.notation == 'P' && intended_move.target_pos[0] != pos_before[0]
      @chess_data.capture(en_passant_vulnerable) unless @chess_data.is_last_move_capture
    end

    # Switch sides after every successful move
    @current_side = @current_side == 1 ? 2 : 1
  end

  def calculate_moves
    @chess_moves.evaluate_moves
  end

  private

  # Parses the chess algebra string in the form of [notation][board_pos]
  # Returns a struct that stores the piece notation and target position
  def parse_algebra(alg_string)
    raise "Invalid string format!" if alg_string.match(/^[PNBRQK]?[a-h]?[1-8]?[a-h][1-8]$/).nil?

    alg_arr = alg_string.split('')

    # If there is no type denoted then set expected type to pawn by default
    expected_type = alg_arr[0].ord < 97 ? alg_arr.shift : 'P'
    pos_arr = [].unshift(alg_arr.pop).unshift(alg_arr.pop)
    
    pos = parse_position(pos_arr)

    unless alg_arr == []
      alg_arr.unshift(nil) if alg_arr[0].ord < 97
    end

    search_pos = parse_position(alg_arr)

    IntendedMove.new(expected_type, pos, pos_arr.join(''), search_pos)
  end

  # Returns the position compatible with chess_data in the form of [col, row]
  # Expects an array that describes the board position ([[file], [rank]])
  # If one of them is nil then it that would be set as -1
  def parse_position(pos_arr)
    col = pos_arr[0].nil? ? -1 : pos_arr[0].ord - 97
    row = pos_arr[1].nil? ? -1 : 8 - pos_arr[1].to_i
    [col, row]
  end
end