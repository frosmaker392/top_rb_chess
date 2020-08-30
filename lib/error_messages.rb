# Module to store all error messages for the Chess class
module ChessErrorMessages
  PIECE_NAME = { 'P' => 'pawn', 'N' => 'knight', 'B' => 'bishop',
               'R' => 'rook', 'Q' => 'queen', 'K' => 'king' }

  SIDE_NAME = { 1 => 'white', 2 => 'black' }

  # No [piece type (notation)]s found on [side name (side)]'s side
  def err_no_piece_found(notation, side)
    "No #{PIECE_NAME[notation]}s found on #{SIDE_NAME[side]}\'s side!"
  end

  # Cannot move [piece type (notation)] to [board pos]
  def err_cannot_move(notation, board_pos)
    "Cannot move #{PIECE_NAME[notation]} to #{board_pos}!"
  end

  # [count] [piece type (notation)]s could move to [board pos]
  # e.g : 2 knights could move to b3
  def err_more_pieces_can_move(count, notation, board_pos)
    "#{count} #{PIECE_NAME[notation]}s could move to #{board_pos}!"
  end
end