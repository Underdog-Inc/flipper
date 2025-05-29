RSpec.describe Flipper::Expressions::Equal do
  describe "#call" do
    it "returns true when equal" do
      expect(described_class.call("basic", "basic")).to be(true)
    end

    it "returns false when not equal" do
      expect(described_class.call("basic", "plus")).to be(false)
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
    it "returns formatted string for string values" do
      left = double("left", in_words: "plan")
      right = double("right", in_words: "basic")
      expect(described_class.in_words(left, right)).to eq("plan is equal to basic")
    end

    it "returns formatted string for numeric values" do
      left = double("left", in_words: "score")
      right = double("right", in_words: "100")
      expect(described_class.in_words(left, right)).to eq("score is equal to 100")
    end

    it "returns formatted string for boolean values" do
      left = double("left", in_words: "active")
      right = double("right", in_words: "true")
      expect(described_class.in_words(left, right)).to eq("active is equal to true")
      left = double("left", in_words: "disabled")
      right = double("right", in_words: "false")
      expect(described_class.in_words(left, right)).to eq("disabled is equal to false")
    end

    it "returns formatted string for mixed value types" do
      left = double("left", in_words: "count")
      right = double("right", in_words: "5")
      expect(described_class.in_words(left, right)).to eq("count is equal to 5")
    end
  end
end
