RSpec.describe Flipper::Expressions::GreaterThan do
  describe "#call" do
    it "returns false when equal" do
      expect(described_class.call(2, 2)).to be(false)
    end

    it "returns true when greater" do
      expect(described_class.call(2, 1)).to be(true)
    end

    it "returns false when less" do
      expect(described_class.call(1, 2)).to be(false)
    end

    it "returns false when value evaluates to nil" do
      expect(described_class.call(nil, 1)).to be(false)
      expect(described_class.call(1, nil)).to be(false)
    end

    it "raises ArgumentError with no arguments" do
      expect { described_class.call }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError with one argument" do
      expect { described_class.call(10) }.to raise_error(ArgumentError)
    end
  end

  describe ".in_words" do
    it "returns formatted string for numeric values" do
      expect(described_class.in_words("score", 100)).to eq("score is greater than 100")
    end

    it "returns formatted string for string values" do
      expect(described_class.in_words("name", "alice")).to eq("name is greater than alice")
    end

    it "returns formatted string for decimal values" do
      expect(described_class.in_words("price", 99.99)).to eq("price is greater than 99.99")
    end

    it "returns formatted string for mixed value types" do
      expect(described_class.in_words("threshold", "50")).to eq("threshold is greater than 50")
    end
  end
end
