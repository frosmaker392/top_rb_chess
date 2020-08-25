require './lib/chess_moves.rb'

IntendedMove = Struct.new(:notation, :target_pos)

class Chess
  def initialize(chess_data)
    @chess_data = chess_data
    @chess_moves = ChessMoves.new(chess_data)
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
    IntendedMove.new(expected_type, pos)
  end

  # Returns the position compatible with chess_data in the form of [col, row]
  # Expects a string that satisfies the regex /^[a-h][1-8]$/ (no error if otherwise)
  def parse_position(pos_string)
    col = pos_string[0].ord - 97
    row = 8 - pos_string[1].to_i
    [col, row]
  end
end
