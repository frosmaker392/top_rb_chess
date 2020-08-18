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
      context "of a pawn" do
        cm = ChessMoves.new(ChessData.new)

        it "that has not moved" do
          cm.evaluate_moves
          expect(cm.possible_moves_at([5, 1])).to eql([[5, 2], [5, 3]])
        end

        it "that has moved" do
          cm.data.move_piece([1, 6], [1, 5])
          cm.evaluate_moves
          expect(cm.possible_moves_at([1, 5])).to eql([[1, 4]])
        end

        it "with an enemy piece on the front-diagonal adjacent square" do
          cm.data.move_by_arr(['26-24', '11-13'])
          cm.evaluate_moves
          expect(cm.possible_moves_at([2, 4])).to eql([[2, 3], [1, 3]])
        end
      end

      it "of a knight" do
        cm = ChessMoves.new(ChessData.new)
        cm.data.move_by_arr(['10-33', '67-44'])
        cm.evaluate_moves
        
        expect(cm.possible_moves_at([3, 3]).sort).to eql([[1,2], [1,4], [2,5], [4,5], 
                                                          [5,2], [5,4]])
        expect(cm.possible_moves_at([4, 4]).sort).to eql([[2,3], [2,5], [3,2], [5,2], 
                                                          [6,3], [6,5]])
      end

      it "of a bishop" do
        cm = ChessMoves.new(ChessData.new)
        cm.data.move_piece([2, 7], [4, 3])
        cm.evaluate_moves

        expect(cm.possible_moves_at([4, 3]).sort).to eql([[2,1], [2,5], [3,2], [3,4], 
                                                          [5,2], [5,4], [6,1], [6,5]])
      end

      it "of a rook" do
        cm = ChessMoves.new(ChessData.new)
        cm.data.move_piece([0, 0], [2, 3])
        cm.evaluate_moves

        expect(cm.possible_moves_at([2, 3]).sort).to eql([[0,3], [1,3], [2,2], [2,4],
                                                          [2,5], [2,6], [3,3], [4,3], 
                                                          [5,3], [6,3], [7,3]])
      end

      it "of a queen" do
        cm = ChessMoves.new(ChessData.new)
        cm.data.move_piece([3,7], [5,3])
        cm.evaluate_moves

        expect(cm.possible_moves_at([5, 3]).sort).to eql([[0,3], [1,3], [2,3], [3,1], 
                                                          [3,3], [3,5], [4,2], [4,3], 
                                                          [4,4], [5,1], [5,2], [5,4], 
                                                          [5,5], [6,2], [6,3], [6,4], 
                                                          [7,1], [7,3], [7,5]])
      end

      it "of a king" do
        cm = ChessMoves.new(ChessData.new)
        cm.data.move_by_arr(['47-44', '46-45', '31-33'])
        cm.evaluate_moves

        expect(cm.possible_moves_at([4, 4]).sort).to eql([[3,3], [3,4], [3,5], [4,3], 
                                                          [5,3], [5,4], [5,5]])
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