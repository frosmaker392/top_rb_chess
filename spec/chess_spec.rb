require './lib/chess.rb'

describe ChessPiece do
  context "Initialise ChessPiece class" do
    it "initialises ChessPiece with notation and side" do
      cp = ChessPiece.new('K', 1)
      expect(cp.debug_str).to eql('K1')
    end

    it "raises error if wrong datatypes are used" do
      expect{ ChessPiece.new('N', 1.5) }.to raise_error("Invalid datatypes!")
    end
  end
end

describe ChessData do
  context "Initialise ChessData class" do
    it "initialises ChessData class with starting chess pieces" do
      cd = ChessData.new
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end
  end

  describe "#at" do
    it "returns the ChessPiece at the specified position" do
      cd = ChessData.new
      expect(cd.at([0, 6]).debug_str).to eql('P1')
    end

    it "can return nil" do
      cd = ChessData.new
      expect(cd.at([3, 3])).to eql(nil)
    end
  end

  describe "#move_piece" do
    it "moves a piece from a point to another" do
      cd = ChessData.new
      cd.move_piece([1, 6], [1, 4])
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "  P1            \n"\
                                  "                \n"\
                                  "P1  P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "ignores any movement rules, regardless of which piece" do
      cd = ChessData.new
      cd.move_piece([3, 0], [5, 4])
      cd.move_piece([0, 7], [0, 5])
      expect(cd.debug_str).to eql("R2N2B2  K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "          Q2    \n"\
                                  "R1              \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "  N1B1Q1K1B1N1R1\n")
    end

    it "does nothing if the starting position is nil" do
      cd = ChessData.new
      cd.move_piece([2, 3], [7, 7])
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "captures a piece that is already at the end position" do
      cd = ChessData.new
      cd.move_piece([0, 6], [0, 1])
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P1P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "  P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end
  end

  context "@captured array stores all captured pieces" do
    it "push the captured ChessPieces into @captured" do
      cd = ChessData.new
      cd.move_piece([0, 6], [0, 1])
      cd.move_piece([1, 6], [1, 1])
      str = cd.captured[0].debug_str + cd.captured[1].debug_str
      expect(str).to eql("P2P2")
    end
  end
end