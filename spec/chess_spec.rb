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
end