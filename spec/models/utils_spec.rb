require "./lib/utils"

describe Utils do
  describe ".is_numeric" do
    it "returns false when not a numeric object" do
      expect(described_class.is_numeric("a")).to eq(false)
      expect(described_class.is_numeric("1")).to eq(false)
    end

    it "returns true when it is a number" do
      expect(described_class.is_numeric(1)).to eq(true)
      expect(described_class.is_numeric(1.0)).to eq(true)
    end

    it "returns false when it is NaN" do
      expect(described_class.is_numeric(Float::NAN)).to eq(false)
    end

    it "throws an error when it is Infinity" do
      expect { described_class.is_numeric(Float::INFINITY) }.to raise_error(JsonataException, /"code":"D1001"/)
    end
  end

  describe ".is_array_of_strings" do
    it "returns false when arg isn't an array" do
      expect(described_class.is_array_of_strings("string")).to eq(false)
    end

    it "returns false when arg is array but not all elements are strings" do
      expect(described_class.is_array_of_strings(["1", 2])).to eq(false)
    end

    it "returns false when arg is array and all elements are strings" do
      expect(described_class.is_array_of_strings(["1", "2"])).to eq(true)
    end
  end

  describe ".is_array_of_numbers" do
    it "returns false when arg isn't an array" do
      expect(described_class.is_array_of_numbers("number")).to eq(false)
    end

    it "returns false when arg is array but not all elements are numbers" do
      expect(described_class.is_array_of_numbers(["1", 2])).to eq(false)
      expect(described_class.is_array_of_numbers([Float::NAN, 2])).to eq(false)
    end

    it "returns false when arg is array and all elements are numbers" do
      expect(described_class.is_array_of_numbers([1, 2.0])).to eq(true)
    end

    it "throws an error when arg is an array and any element is Infinity" do
      expect { described_class.is_array_of_numbers([Float::INFINITY]) }.to raise_error(JsonataException, /"code":"D1001"/)
    end
  end

  describe ".is_deep_equal" do
    it "returns false when types don't match" do
      lhs = []
      rhs = {}
      expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
    end

    describe "arrays" do
      describe "of numbers" do
        it "returns true when they match" do
          lhs = [1,2]
          rhs = [1,2]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(true)
        end

        it "returns false when the number of elements don't match" do
          lhs = [1,2]
          rhs = [1,2,3,4]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end

        it "returns false when the number of elements match, but the elements don't" do
          lhs = [1,2]
          rhs = [1,20]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end
      end

      describe "of strings" do
        it "returns true when they match" do
          lhs = ["1","2"]
          rhs = ["1","2"]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(true)
        end

        it "returns false when the number of elements don't match" do
          lhs = ["1","2"]
          rhs = ["1","2","3","4"]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end

        it "returns false when the number of elements match, but the elements don't" do
          lhs = ["1","2"]
          rhs = ["1","20"]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end
      end
      
      describe "of hashes" do
        it "returns true when they match" do
          lhs = [{"one" => 1}, {"two" => 2}]
          rhs = [{"one" => 1}, {"two" => 2}]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(true)
        end

        it "returns false when the number of elements don't match" do
          lhs = [{"one" => 1}, {"two" => 2}]
          rhs = [{"one" => 1}, {"two" => 2}, {"three" => 3}]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end

        it "returns false when the number of elements match, but the elements don't" do
          lhs = [{"one" => 1}, {"two" => 2}]
          rhs = [{"one" => 1}, {"twenty" => 20}]
          expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
        end
      end
    end
    
    describe "hashes" do
      it "returns true when they match regardless of key type" do
        lhs = [{"one" => 1}, {"two" => 2}]
        rhs = [{one: 1}, {two: 2}]

        expect(described_class.is_deep_equal(lhs, rhs)).to eq(true)
      end

      it "returns false when the number of elements don't match" do
        lhs = [{"one" => 1, "two" => 2}]
        rhs = [{"one" => 1, "two" => 2, "three" => 3}]
        expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
      end

      it "returns false when the number of elements match, but the keys don't" do
        lhs = [{"one" => 1, "two" => 2}]
        rhs = [{"one" => 1, "twenty" => 2}]
        expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
      end

      it "returns false when the number of elements match, but the values don't" do
        lhs = [{"one" => 1, "two" => 2}]
        rhs = [{"one" => 1, "two" => 20}]
        expect(described_class.is_deep_equal(lhs, rhs)).to eq(false)
      end
    end
  end

  describe ".string_to_array" do
    it "returns an empty array if arg is not a string" do
      expect(described_class.string_to_array(1234)).to eq([])
    end

    it "returns an array with separated characters if arg is a string" do
      expect(described_class.string_to_array("1234")).to eq(["1","2","3","4"])
    end
  end
end
