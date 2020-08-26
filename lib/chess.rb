require './lib/chess_moves.rb'

IntendedMove = Struct.new(:notation, :target_pos, :board_pos)

PIECE_NAME = { 'P' => 'pawn', 'N' => 'knight', 'B' => 'bishop',
               'R' => 'rook', 'Q' => 'queen', 'K' => 'king' }

class Chess
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

    valid_pieces = []
    @chess_data.pieces_by_side[@current_side].each do |piece|
      next unless piece.notation == intended_move.notation

      valid_pieces << piece if @chess_moves.possible_moves[piece].include?(intended_move.target_pos)
    end

    raise "Cannot move #{PIECE_NAME[intended_move.notation]} to #{intended_move.board_pos}!" if valid_pieces == []
    raise "#{valid_pieces.length} #{PIECE_NAME[intended_move.notation]}s could move to #{intended_move.board_pos}!" if valid_pieces.length > 1

    @chess_data.move_piece(valid_pieces[0].position, intended_move.target_pos)

    # Switch sides after every successful move
    @current_side = @current_side == 1 ? 2 : 1
  end

  private

  # Parses the chess algebra string in the form of [notation][board_pos]
  # Returns a struct that stores the piece notation and target position
  def parse_algebra(alg_string)
    raise "Invalid string format!" if alg_string.match(/^[PNBRQK]?[a-h][1-8]$/).nil?

    is_type_denoted = alg_string[0].ord < 97

    # If there is no type denoted then set expected type to pawn by default
    expected_type = is_type_denoted ? alg_string[0] : 'P'
    pos_string = ''

    if is_type_denoted then pos_string << alg_string[1] << alg_string[2]
    else pos_string << alg_string[0] << alg_string[1] end
    
    pos = parse_position(pos_string)
    IntendedMove.new(expected_type, pos, pos_string)
  end

  # Returns the position compatible with chess_data in the form of [col, row]
  # Expects a string that satisfies the regex /^[a-h][1-8]$/ (no error if otherwise)
  def parse_position(pos_string)
    col = pos_string[0].ord - 97
    row = 8 - pos_string[1].to_i
    [col, row]
  end
end
