RSpec.describe Flipper::Expressions::All do
  describe "#call" do
    it "returns true if all args evaluate as true" do
      expect(described_class.call(true, true)).to be(true)
    end

    it "returns false if any args evaluate as false" do
      expect(described_class.call(false, true)).to be(false)
    end

    it "returns true with empty args" do
      expect(described_class.call).to be(true)
    end
  end

  describe ".in_words" do
    it "returns 'all 1 condition' for single condition" do
      expect(described_class.in_words("condition1")).to eq("all 1 condition")
    end

    it "returns 'all 2 conditions' for multiple conditions" do
      expect(described_class.in_words("condition1", "condition2")).to eq("all 2 conditions")
    end

    it "returns 'all 0 conditions' for no conditions" do
      expect(described_class.in_words).to eq("all 0 conditions")
    end

    it "returns 'all 4 conditions' for four conditions" do
      expect(described_class.in_words("c1", "c2", "c3", "c4")).to eq("all 4 conditions")
    end
  end
end
