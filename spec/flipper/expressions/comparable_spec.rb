RSpec.describe Flipper::Expressions::Comparable do
  describe ".in_words" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.in_words("left", "right") }.to raise_error(NotImplementedError)
    end
  end
end
