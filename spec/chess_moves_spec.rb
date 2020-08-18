require './lib/chess_moves.rb'
require './lib/chess_data.rb'

describe ChessMoves do
  describe "#initialize" do
    it "stores a ChessData object by reference, accessible by @data" do
      cd = ChessData.new
      cm = ChessMoves.new(cd)
      cd.move_piece([1, 6], [1, 4])
      expect(cm.data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                       "P2P2P2P2P2P2P2P2\n"\
                                       "                \n"\
                                       "                \n"\
                                       "  P1            \n"\
                                       "                \n"\
                                       "P1  P1P1P1P1P1P1\n"\
                                       "R1N1B1Q1K1B1N1R1\n")
    end
  end

  context "@possible_moves is a hash that stores all possible moves" do
    it "contains an empty array by default" do
      cm = ChessMoves.new(ChessData.new)
      expect(cm.possible_moves[cm.data.at([0, 0])]).to eql([])
    end

    it "stores a nil value for @possible_moves[nil]" do
      cm = ChessMoves.new(ChessData.new)
      expect(cm.possible_moves[cm.data.at([0, 3])]).to eql(nil)
    end
  end

  describe "#possible_moves_at(position)" do
    it "returns the array of possible moves given the position of the piece" do
      cm = ChessMoves.new(ChessData.new)
      expect(cm.possible_moves_at([0,0])).to eql([])
    end
  end

  describe "#evaluate_moves" do
    context "evaluates the possible moves" do
      context "... of a pawn" do
        cm = ChessMoves.new(ChessData.new)

        context "... that has not moved" do

        end

        context "... that has moved" do

        end

        context "... with an enemy piece on the front-diagonal adjacent square" do

        end
      end

      context "... of a knight" do

      end

      context "... of a bishop" do

      end

      context "... of a rook" do

      end

      context "... of a queen" do

      end

      context "... of a king" do

      end
    end

    context "also includes special moves" do
      it "pawn : en-passant" do

      end

      it "king : king-side castling" do

      end

      it "king : queen-side castling" do

      end
    end
  end
end