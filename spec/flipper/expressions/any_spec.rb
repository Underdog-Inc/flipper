RSpec.describe Flipper::Expressions::Any do
  describe "#call" do
    it "returns true if any args evaluate as true" do
      expect(described_class.call(true, false)).to be(true)
    end

    it "returns false if all args evaluate as false" do
      expect(described_class.call(false, false)).to be(false)
    end

    it "returns false with empty args" do
      expect(described_class.call).to be(false)
    end
  end

  describe ".in_words" do
    it "returns 'any 1 condition' for single condition" do
      expect(described_class.in_words("condition1")).to eq("any 1 condition")
    end

    it "returns 'any 2 conditions' for multiple conditions" do
      expect(described_class.in_words("condition1", "condition2")).to eq("any 2 conditions")
    end

    it "returns 'any 0 conditions' for no conditions" do
      expect(described_class.in_words).to eq("any 0 conditions")
    end

    it "returns 'any 3 conditions' for three conditions" do
      expect(described_class.in_words("cond1", "cond2", "cond3")).to eq("any 3 conditions")
    end
  end
end
