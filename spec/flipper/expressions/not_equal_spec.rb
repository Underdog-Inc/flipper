RSpec.describe Flipper::Expressions::NotEqual do
  describe "#call" do
    it "returns true when not equal" do
      expect(described_class.call("basic", "plus")).to be(true)
    end

    it "returns false when equal" do
      expect(described_class.call("basic", "basic")).to be(false)
    end

    it "raises ArgumentError for more arguments" do
      expect { described_class.call(20, 10, 20).evaluate }.to raise_error(ArgumentError)
    end
  end

  describe ".in_words" do
    it "returns formatted string for string values" do
      left = double("left", in_words: "status")
      right = double("right", in_words: "inactive")
      expect(described_class.in_words(left, right)).to eq("status is not equal to inactive")
    end

    it "returns formatted string for numeric values" do
      left = double("left", in_words: "count")
      right = double("right", in_words: "0")
      expect(described_class.in_words(left, right)).to eq("count is not equal to 0")
    end

    it "returns formatted string for boolean values" do
      left = double("left", in_words: "enabled")
      right = double("right", in_words: "false")
      expect(described_class.in_words(left, right)).to eq("enabled is not equal to false")
    end

    it "returns formatted string for mixed value types" do
      left = double("left", in_words: "version")
      right = double("right", in_words: "1.5")
      expect(described_class.in_words(left, right)).to eq("version is not equal to 1.5")
    end
  end
end
