RSpec.describe Flipper::Expressions::GreaterThanOrEqualTo do
  describe "#call" do
    it "returns true when equal" do
      expect(described_class.call(2, 2)).to be(true)
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
      expect(described_class.in_words("age", 18)).to eq("age is greater than or equal to 18")
    end

    it "returns formatted string for decimal values" do
      expect(described_class.in_words("minimum", 5.5)).to eq("minimum is greater than or equal to 5.5")
    end

    it "returns formatted string for string values" do
      expect(described_class.in_words("level", "intermediate")).to eq("level is greater than or equal to intermediate")
    end

    it "returns formatted string for zero values" do
      expect(described_class.in_words("balance", 0)).to eq("balance is greater than or equal to 0")
    end
  end
end
