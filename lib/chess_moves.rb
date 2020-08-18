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
end