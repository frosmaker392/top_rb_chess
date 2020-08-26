require './lib/chess.rb'

describe Chess do
  context 'accessible variables :' do
    it '@chess_data stores the ChessData object linked to this Chess object' do
      c = Chess.new(ChessData.new)
      expect(c.chess_data.nil?).to be false
      expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                            "P2P2P2P2P2P2P2P2\n"\
                                            "                \n"\
                                            "                \n"\
                                            "                \n"\
                                            "                \n"\
                                            "P1P1P1P1P1P1P1P1\n"\
                                            "R1N1B1Q1K1B1N1R1\n")
    end

    it '@chess_moves stores the ChessMoves object linked to this Chess object' do
      c = Chess.new(ChessData.new)
      expect(c.chess_moves.nil?).to be false
      c.chess_moves.evaluate_moves
      expect(c.chess_moves.possible_moves_at([0, 1])).to eql([[0, 2], [0, 3]])
    end
  end

  describe '#try_move' do
    context "basic functions :" do
      it "moves a piece given the algebraic string, starting with 1 (white)" do
        c = Chess.new(ChessData.new)
        c.chess_moves.evaluate_moves
        c.try_move('a4')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "                \n"\
                                              "P1              \n"\
                                              "                \n"\
                                              "  P1P1P1P1P1P1P1\n"\
                                              "R1N1B1Q1K1B1N1R1\n")
      end

      it "switches to the black (2) side after white moves, and vice versa" do
        c = Chess.new(ChessData.new)
        c.chess_moves.evaluate_moves
        c.try_move('a4')
        c.chess_moves.evaluate_moves
        c.try_move('a5')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "  P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "P2              \n"\
                                              "P1              \n"\
                                              "                \n"\
                                              "  P1P1P1P1P1P1P1\n"\
                                              "R1N1B1Q1K1B1N1R1\n")
      end

      it "moves a knight" do
        c = Chess.new(ChessData.new)
        c.chess_moves.evaluate_moves
        c.try_move('Nf3')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "                \n"\
                                              "                \n"\
                                              "          N1    \n"\
                                              "P1P1P1P1P1P1P1P1\n"\
                                              "R1N1B1Q1K1B1  R1\n")
      end

      it "moves a bishop" do
        c = Chess.new(ChessData.new)
        c.chess_data.actions_from_arr(['46-45', '31-33'])
        c.chess_moves.evaluate_moves
        c.try_move('Bb5')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2  P2P2P2P2\n"\
                                              "                \n"\
                                              "  B1  P2        \n"\
                                              "                \n"\
                                              "        P1      \n"\
                                              "P1P1P1P1  P1P1P1\n"\
                                              "R1N1B1Q1K1  N1R1\n")
      end

      it "moves a rook" do
        c = Chess.new(ChessData.new)
        c.chess_data.actions_from_arr(['76-65'])
        c.chess_moves.evaluate_moves
        c.try_move('Rh5')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "              R1\n"\
                                              "                \n"\
                                              "            P1  \n"\
                                              "P1P1P1P1P1P1P1  \n"\
                                              "R1N1B1Q1K1B1N1  \n")
      end

      it "moves a queen" do
        c = Chess.new(ChessData.new)
        c.chess_data.actions_from_arr(['26-24'])
        c.chess_moves.evaluate_moves
        c.try_move('Qa4')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "                \n"\
                                              "Q1  P1          \n"\
                                              "                \n"\
                                              "P1P1  P1P1P1P1P1\n"\
                                              "R1N1B1  K1B1N1R1\n")
      end
    end

    context "special functions :" do
      it "moves the specific piece given the file letter" do
        cd = ChessData.new
        cd.actions_from_arr(['21-25'])
        c = Chess.new(cd)
        c.chess_moves.evaluate_moves
        c.try_move('bc3')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2  P2P2P2P2P2\n"\
                                              "                \n"\
                                              "                \n"\
                                              "                \n"\
                                              "    P1          \n"\
                                              "P1  P1P1P1P1P1P1\n"\
                                              "R1N1B1Q1K1B1N1R1\n")
      end

      it "moves the specific piece given the rank number" do
        cd = ChessData.new
        cd.actions_from_arr(['07-72', '77-75'])
        c = Chess.new(cd)
        c.chess_moves.evaluate_moves
        c.try_move('R3h5')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "              R1\n"\
                                              "              R1\n"\
                                              "                \n"\
                                              "                \n"\
                                              "P1P1P1P1P1P1P1P1\n"\
                                              "  N1B1Q1K1B1N1  \n")
      end

      it "moves the specific piece given the exact position" do
        cd = ChessData.new
        cd.actions_from_arr(['66-74', 'p56Q', 'p76Q', 'p74Q'])
        c = Chess.new(cd)
        c.chess_moves.evaluate_moves
        c.try_move('Qh2f4')
        expect(c.chess_data.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                              "P2P2P2P2P2P2P2P2\n"\
                                              "                \n"\
                                              "                \n"\
                                              "          Q1  Q1\n"\
                                              "                \n"\
                                              "P1P1P1P1P1Q1    \n"\
                                              "R1N1B1Q1K1B1N1R1\n")
      end
    end

    context "error handling :" do
      it "raises error for invalid algebraic strings (includes empty)" do
        c = Chess.new(ChessData.new)
        c.chess_moves.evaluate_moves
        expect{ c.try_move('a2Q') }.to raise_error("Invalid string format!")
      end

      context "raises error for a move that cannot be carried out" do
        it "for a pawn" do
          c = Chess.new(ChessData.new)
          c.chess_moves.evaluate_moves
          expect{ c.try_move('b5') }.to raise_error("Cannot move pawn to b5!")
        end

        it "for another piece" do
          c = Chess.new(ChessData.new)
          c.chess_moves.evaluate_moves
          expect{ c.try_move('Bb5') }.to raise_error("Cannot move bishop to b5!")
        end

        it "when that piece does not exist on that side" do
          c = Chess.new(ChessData.new)
          c.chess_data.actions_from_arr(['x17', 'x67'])
          c.chess_moves.evaluate_moves
          expect{ c.try_move('Nc3') }.to raise_error("No knights found on white's side!")
        end
      end

      context "raises error when more than one piece can make that move" do
        it "for two pieces" do
          cd = ChessData.new
          cd.actions_from_arr(['21-25'])
          c = Chess.new(cd)
          c.chess_moves.evaluate_moves
          expect{ c.try_move('c3') }.to raise_error("2 pawns could move to c3!")
        end

        it "for three pieces" do
          cd = ChessData.new
          cd.actions_from_arr(['x00', 'x10', 'x20', 'x01', 'x11', 'x21'])
          cd.actions_from_arr(['06-00', 'p00Q','16-10', 'p10Q','26-20', 'p20Q'])
          c = Chess.new(cd)
          c.chess_moves.evaluate_moves
          expect{ c.try_move('Qb7') }.to raise_error("3 queens could move to b7!")
        end

        it "for two pieces (even with a specified file)" do
          cd = ChessData.new
          cd.actions_from_arr(['66-74', 'p56Q', 'p76Q', 'p74Q'])
          c = Chess.new(cd)
          c.chess_moves.evaluate_moves
          expect{ c.try_move('Qhf4') }.to raise_error("2 queens could move to f4!")
        end
      end
    end
  end
end