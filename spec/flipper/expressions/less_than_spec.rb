RSpec.describe Flipper::Expressions::LessThan do
  describe "#call" do
    it "returns false when equal" do
      expect(described_class.call(2, 2)).to be(false)
    end

    it "returns true when less" do
      expect(described_class.call(1, 2)).to be(true)
    end

    it "returns true when less with args that need evaluation" do
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
      expect(described_class.in_words("price", 50)).to eq("price is less than 50")
    end

    it "returns formatted string for decimal values" do
      expect(described_class.in_words("discount", 0.5)).to eq("discount is less than 0.5")
    end

    it "returns formatted string for string values" do
      expect(described_class.in_words("priority", "high")).to eq("priority is less than high")
    end

    it "returns formatted string for zero comparison" do
      expect(described_class.in_words("value", 0)).to eq("value is less than 0")
    end
  end
end
