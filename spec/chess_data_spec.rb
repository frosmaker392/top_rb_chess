require './lib/chess_data.rb'

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

    it "changes @position of the ChessPiece involved" do
      cd = ChessData.new
      expect(cd.at([0, 6]).position).to eql([0, 6])
      cd.move_piece([0, 6], [0, 1])
      expect(cd.at([0, 1]).position).to eql([0, 1])
    end

    it "sets @position of captured pieces to [-1, -1]" do
      cd = ChessData.new
      cd.move_piece([0, 0], [0, 7])
      cd.move_piece([5, 6], [5, 1])
      cd.captured.each do |piece|
        expect(piece.position).to eql([-1, -1])
      end
    end
    
    it "increments @num_of_moves variable of piece by 1" do
      cd = ChessData.new
      cd.move_piece([0, 1], [0, 2])
      cd.move_piece([0, 2], [0, 3])
      cd.move_piece([0, 3], [0, 4])

      expect(cd.at([0, 0]).num_of_moves).to eql(0)
      expect(cd.at([0, 4]).num_of_moves).to eql(3)
    end
  end

  describe "#capture(piece)" do
    it "captures a piece by emptying the square it's occupying" do
      cd = ChessData.new
      cd.capture(cd.at([0, 0]))
      expect(cd.debug_str).to eql("  N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
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

  context "@actions array stores all actions (moves, captures, promotions) since the default layout" do
    it "stores a move in the form of '[from]-[to]' (no spaces)" do
      cd = ChessData.new
      cd.move_piece([2, 1], [2, 3])
      expect(cd.actions).to eql(['21-23'])
    end

    it "stores multiple actions" do
      cd = ChessData.new
      cd.move_piece([2, 1], [2, 3])
      cd.move_piece([1, 1], [1, 2])
      cd.move_piece([5, 6], [5, 4])
      expect(cd.actions).to eql(['21-23', '11-12', '56-54'])
    end

    it "stores captures and promotions correctly" do
      cd = ChessData.new
      cd.capture(cd.at([2, 0]))
      cd.promote(cd.at([6, 6]))

      expect(cd.actions).to eql(['x20', 'p66Q'])
    end
  end

  context "@en_passant_vulnerable stores the last pawn that has jumped two squares" do
    it "stores it after move has been called" do
      cd = ChessData.new
      cd.action_from_str('26-24')

      expect(cd.en_passant_vulnerable.nil?).to be false
    end

    it "reverts to nil on the next move that is not the two-square pawn jump" do
      cd = ChessData.new
      cd.actions_from_arr(['26-24', '16-15'])

      expect(cd.en_passant_vulnerable.nil?).to be true
    end
  end

  context "@pieces_by_side (hash)" do
    cd = ChessData.new

    it "stores every piece of each side into an array, which is a value in the hash" do
      debug_str_arr = cd.pieces_by_side[1].map { |piece| piece.debug_str }.sort
      expect(debug_str_arr).to eql(['B1', 'B1', 'K1', 'N1', 'N1', 
                                    'P1', 'P1', 'P1', 'P1', 'P1', 
                                    'P1', 'P1', 'P1', 'Q1', 'R1', 
                                    'R1'])
    end

    it "removes a piece once that piece gets captured" do
      cd.action_from_str('x06')
      debug_str_arr = cd.pieces_by_side[1].map { |piece| piece.debug_str }.sort
      expect(debug_str_arr).to eql(['B1', 'B1', 'K1', 'N1', 'N1', 
                                    'P1', 'P1', 'P1', 'P1', 'P1', 
                                    'P1', 'P1', 'Q1', 'R1', 'R1'])
      
      debug_str_arr2 = cd.pieces_by_side[2].map { |piece| piece.debug_str }.sort
      expect(debug_str_arr2).to eql(['B2', 'B2', 'K2', 'N2', 'N2', 
                                    'P2', 'P2', 'P2', 'P2', 'P2', 
                                    'P2', 'P2', 'P2', 'Q2', 'R2', 
                                    'R2'])
    end
  end

  describe "#action_from_str" do
    it "parses a move string into from and to coords and moves the pieces" do
      cd = ChessData.new
      cd.action_from_str("16-14")
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "  P1            \n"\
                                  "                \n"\
                                  "P1  P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "moves pieces successively" do
      cd = ChessData.new
      cd.action_from_str("30-54")
      cd.action_from_str("07-05")
      expect(cd.debug_str).to eql("R2N2B2  K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "          Q2    \n"\
                                  "R1              \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "  N1B1Q1K1B1N1R1\n")
    end

    it "executes a capture if the string has the format 'x[pos]'" do
      cd = ChessData.new
      cd.action_from_str("x61")
      cd.action_from_str("x77")
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2  P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1  \n")
    end
    
    it "executes a promotion for string of format 'p[pos][new_notation]'" do
      cd = ChessData.new
      cd.action_from_str("p71Q")
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2P2Q2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "raises error if string is in wrong format (move)" do
      cd = ChessData.new
      expect{ cd.action_from_str('1-234') }.to raise_error("Invalid format for move string!")
    end

    it "raises error if string is in wrong format (capture)" do
      cd = ChessData.new
      expect{ cd.action_from_str('x-12') }.to raise_error("Invalid format for move string!")
    end
  end

  describe "#actions_from_arr" do
    it "executes all the actions given in an array consecutively" do
      cd = ChessData.new
      cd.actions_from_arr(['46-44', '41-43', '67-55', '10-22', '57-13', '01-02'])
      expect(cd.debug_str).to eql("R2  B2Q2K2B2N2R2\n"\
                                  "  P2P2P2  P2P2P2\n"\
                                  "P2  N2          \n"\
                                  "  B1    P2      \n"\
                                  "        P1      \n"\
                                  "          N1    \n"\
                                  "P1P1P1P1  P1P1P1\n"\
                                  "R1N1B1Q1K1    R1\n")
    end
  end

  describe "#promote" do
    it "promotes a pawn to a queen by default, ignoring the position of the pawn" do
      cd = ChessData.new
      cd.promote(cd.at([1, 1]))
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2Q2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "promotes a pawn to a desired piece if stated" do
      cd = ChessData.new
      cd.promote(cd.at([1, 1]), 'N')
      expect(cd.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2N2P2P2P2P2P2P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1R1\n")
    end

    it "raises error if the given piece is nil/other than a pawn" do
      cd = ChessData.new
      expect{ cd.promote(cd.at([2, 7])) }.to raise_error("Intended piece is nil/not a pawn!")
    end
  end

  context "JSON serialization" do
    it "can serialize the @actions variable into JSON and rebuild the ChessData object from the JSON" do
      cd = ChessData.new
      cd.actions_from_arr(['46-44', '41-43', '67-55', '10-22', '57-13', '01-02'])
      json_str = cd.to_json

      cd2 = ChessData.from_json(json_str)
      expect(cd2.debug_str).to eql("R2  B2Q2K2B2N2R2\n"\
                                  "  P2P2P2  P2P2P2\n"\
                                  "P2  N2          \n"\
                                  "  B1    P2      \n"\
                                  "        P1      \n"\
                                  "          N1    \n"\
                                  "P1P1P1P1  P1P1P1\n"\
                                  "R1N1B1Q1K1    R1\n")
    end

    it "serializes captures correctly" do
      cd = ChessData.new
      cd.capture(cd.at([6, 1]))
      cd.capture(cd.at([7, 7]))
      json_str = cd.to_json

      cd2 = ChessData.from_json(json_str)
      expect(cd2.debug_str).to eql("R2N2B2Q2K2B2N2R2\n"\
                                  "P2P2P2P2P2P2  P2\n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "                \n"\
                                  "P1P1P1P1P1P1P1P1\n"\
                                  "R1N1B1Q1K1B1N1  \n")
    end
  end
end