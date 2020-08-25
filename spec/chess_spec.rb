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
  end
end