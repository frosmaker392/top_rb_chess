describe ChessPiece do
  context "Initialise ChessPiece class" do
    it "initialises ChessPiece with notation and side" do
      cp = ChessPiece.new('K', 1)
      expect(cp.debug_str).to eql('K1')
    end
  end
end

describe ChessData do
  context "Initialise ChessData class" do
    it "initalises ChessData class with an empty 8x8 grid of nils" do
      cd = ChessData.new
      expect(cd.debug_str).to eql("                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n")
    end

    it "initialises ChessData class with @default_grid = true (grid has starting chess pieces)" do
      cd = ChessData.new(true)
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