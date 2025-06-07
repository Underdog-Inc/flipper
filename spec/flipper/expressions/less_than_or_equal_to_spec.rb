RSpec.describe Flipper::Expressions::LessThanOrEqualTo do
  describe "#call" do
    it "returns true when equal" do
      expect(described_class.call(2, 2)).to be(true)
    end

    it "returns true when less" do
      expect(described_class.call(1, 2)).to be(true)
    end

    it "returns false when greater" do
      expect(described_class.call(2, 1)).to be(false)
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
      expect(described_class.in_words("limit", 100)).to eq("limit is less than or equal to 100")
    end

    it "returns formatted string for decimal values" do
      expect(described_class.in_words("threshold", 0.75)).to eq("threshold is less than or equal to 0.75")
    end

    it "returns formatted string for string values" do
      expect(described_class.in_words("category", "premium")).to eq("category is less than or equal to premium")
    end

    it "returns formatted string for negative values" do
      expect(described_class.in_words("temperature", -5)).to eq("temperature is less than or equal to -5")
    end
  end
end
