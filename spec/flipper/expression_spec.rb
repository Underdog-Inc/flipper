require 'flipper/expression'

RSpec.describe Flipper::Expression do
  describe "#build" do
    it "can build Equal" do
      expression = described_class.build({
        "Equal" => [
          "basic",
          "basic",
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::Equal)
      expect(expression.args).to eq([
        Flipper.constant("basic"),
        Flipper.constant("basic"),
      ])
    end

    it "can build GreaterThanOrEqualTo" do
      expression = described_class.build({
        "GreaterThanOrEqualTo" => [
          2,
          1,
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::GreaterThanOrEqualTo)
      expect(expression.args).to eq([
        Flipper.constant(2),
        Flipper.constant(1),
      ])
    end

    it "can build GreaterThan" do
      expression = described_class.build({
        "GreaterThan" => [
          2,
          1,
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::GreaterThan)
      expect(expression.args).to eq([
        Flipper.constant(2),
        Flipper.constant(1),
      ])
    end

    it "can build LessThanOrEqualTo" do
      expression = described_class.build({
        "LessThanOrEqualTo" => [
          2,
          1,
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::LessThanOrEqualTo)
      expect(expression.args).to eq([
        Flipper.constant(2),
        Flipper.constant(1),
      ])
    end

    it "can build LessThan" do
      expression = described_class.build({
        "LessThan" => [2, 1]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::LessThan)
      expect(expression.args).to eq([
        Flipper.constant(2),
        Flipper.constant(1),
      ])
    end

    it "can build NotEqual" do
      expression = described_class.build({
        "NotEqual" => [
          "basic",
          "plus",
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::NotEqual)
      expect(expression.args).to eq([
        Flipper.constant("basic"),
        Flipper.constant("plus"),
      ])
    end

    it "can build Number" do
      expression = described_class.build(1)

      expect(expression).to be_instance_of(Flipper::Expression::Constant)
      expect(expression.value).to eq(1)
    end

    it "can build Percentage" do
      expression = described_class.build({
        "Percentage" => [1]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::Percentage)
      expect(expression.args).to eq([Flipper.constant(1)])
    end

    it "can build PercentageOfActors" do
      expression = described_class.build({
        "PercentageOfActors" => [
          "User;1",
          40,
        ]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::PercentageOfActors)
      expect(expression.args).to eq([
        Flipper.constant("User;1"),
        Flipper.constant(40),
      ])
    end

    it "can build String" do
      expression = described_class.build("basic")

      expect(expression).to be_instance_of(Flipper::Expression::Constant)
      expect(expression.value).to eq("basic")
    end

    it "can build Property" do
      expression = described_class.build({
        "Property" => ["flipper_id"]
      })

      expect(expression).to be_instance_of(Flipper::Expression)
      expect(expression.function).to be(Flipper::Expressions::Property)
      expect(expression.args).to eq([Flipper.constant("flipper_id")])
    end
  end

  describe "#eql?" do
    it "returns true for same class and args" do
      expression = described_class.build("foo")
      other = described_class.build("foo")
      expect(expression.eql?(other)).to be(true)
    end

    it "returns false for different class" do
      expression = described_class.build("foo")
      other = Object.new
      expect(expression.eql?(other)).to be(false)
    end

    it "returns false for different args" do
      expression = described_class.build("foo")
      other = described_class.build("bar")
      expect(expression.eql?(other)).to be(false)
    end
  end

  describe "#==" do
    it "returns true for same class and args" do
      expression = described_class.build("foo")
      other = described_class.build("foo")
      expect(expression == other).to be(true)
    end

    it "returns false for different class" do
      expression = described_class.build("foo")
      other = Object.new
      expect(expression == other).to be(false)
    end

    it "returns false for different args" do
      expression = described_class.build("foo")
      other = described_class.build("bar")
      expect(expression == other).to be(false)
    end
  end

  describe "#in_words" do
    it "returns human-readable text for simple Equal expression" do
      expression = described_class.build({"Equal" => ["plan", "basic"]})
      expect(expression.in_words).to eq("plan is equal to basic")
    end

    it "returns human-readable text for simple NotEqual expression" do
      expression = described_class.build({"NotEqual" => ["status", "inactive"]})
      expect(expression.in_words).to eq("status is not equal to inactive")
    end

    it "returns human-readable text for GreaterThan expression" do
      expression = described_class.build({"GreaterThan" => ["score", 100]})
      expect(expression.in_words).to eq("score is greater than 100")
    end

    it "returns human-readable text for LessThanOrEqualTo expression" do
      expression = described_class.build({"LessThanOrEqualTo" => ["limit", 50]})
      expect(expression.in_words).to eq("limit is less than or equal to 50")
    end

    it "returns human-readable text for complex Any expression" do
      expression = described_class.build({
        "Any" => [
          {"Equal" => ["plan", "basic"]},
          {"GreaterThan" => ["score", 100]}
        ]
      })
      expect(expression.in_words).to eq("any 2 conditions")
    end

    it "returns human-readable text for complex All expression" do
      expression = described_class.build({
        "All" => [
          {"Equal" => ["status", "active"]},
          {"GreaterThanOrEqualTo" => ["age", 18]},
          {"LessThan" => ["price", 100]}
        ]
      })
      expect(expression.in_words).to eq("all 3 conditions")
    end

    it "returns human-readable text for empty Any expression" do
      expression = described_class.build({"Any" => []})
      expect(expression.in_words).to eq("any 0 conditions")
    end

    it "returns human-readable text for single condition All expression" do
      expression = described_class.build({"All" => [{"Equal" => ["single", "condition"]}]})
      expect(expression.in_words).to eq("all 1 condition")
    end

    it "returns human-readable text for Property-based simple expression" do
      expression = described_class.build({
        "Equal" => [
          {"Property" => ["age"]},
          21
        ]
      })
      expect(expression.in_words).to eq("age is equal to 21")
    end

    it "returns human-readable text for Property-based GreaterThanOrEqualTo expression" do
      expression = described_class.build({
        "GreaterThanOrEqualTo" => [
          {"Property" => ["score"]},
          100
        ]
      })
      expect(expression.in_words).to eq("score is greater than or equal to 100")
    end

    it "returns human-readable text for complex expression with Properties" do
      expression = described_class.build({
        "Any" => [
          {"Equal" => [{"Property" => ["plan"]}, "premium"]},
          {"GreaterThan" => [{"Property" => ["age"]}, 65]}
        ]
      })
      expect(expression.in_words).to eq("any 2 conditions")
    end
  end
end
