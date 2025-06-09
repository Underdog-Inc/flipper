require 'flipper/ui/decorators/expression'

RSpec.describe Flipper::UI::Decorators::Expression do
  let(:simple_expression) { Flipper.property(:plan).eq("basic") }
  let(:nil_expression) { nil }
  let(:complex_any_expression) { Flipper.any(Flipper.property(:plan).eq("basic"), Flipper.property(:age).gte(18)) }
  let(:complex_all_expression) { Flipper.all(Flipper.property(:status).eq("active"), Flipper.property(:score).gt(100)) }

  describe "with a simple expression" do
    subject { described_class.new(simple_expression) }

    it "delegates to the underlying expression" do
      expect(subject.expression).to be(simple_expression)
      expect(subject.name).to eq(simple_expression.name)
      expect(subject.args).to eq(simple_expression.args)
    end

    it "returns correct form_data for simple expression" do
      expect(subject.form_data).to eq({
        type: "property",
        property: "plan",
        operator: "eq",
        value: "basic",
        has_expression: true
      })
    end
  end

  describe "with nil expression" do
    subject { described_class.new(nil_expression) }

    it "handles nil gracefully" do
      expect(subject.expression).to be_nil
    end

    it "returns default form_data for nil expression" do
      expect(subject.form_data).to eq({
        type: "property",
        has_expression: false
      })
    end
  end

  describe "with complex any expression" do
    subject { described_class.new(complex_any_expression) }

    it "returns correct form_data for complex any expression" do
      form_data = subject.form_data
      expect(form_data[:type]).to eq("any")
      expect(form_data[:has_expression]).to be(true)
      expect(form_data[:expressions]).to be_an(Array)
      expect(form_data[:expressions].length).to eq(2)
      
      # Check first expression
      first_expr = form_data[:expressions][0]
      expect(first_expr[:property]).to eq("plan")
      expect(first_expr[:operator]).to eq("eq")
      expect(first_expr[:value]).to eq("basic")
      
      # Check second expression
      second_expr = form_data[:expressions][1]
      expect(second_expr[:property]).to eq("age")
      expect(second_expr[:operator]).to eq("gte")
      expect(second_expr[:value]).to eq("18")
    end
  end

  describe "with complex all expression" do
    subject { described_class.new(complex_all_expression) }

    it "returns correct form_data for complex all expression" do
      form_data = subject.form_data
      expect(form_data[:type]).to eq("all")
      expect(form_data[:has_expression]).to be(true)
      expect(form_data[:expressions]).to be_an(Array)
      expect(form_data[:expressions].length).to eq(2)
      
      # Check first expression
      first_expr = form_data[:expressions][0]
      expect(first_expr[:property]).to eq("status")
      expect(first_expr[:operator]).to eq("eq")
      expect(first_expr[:value]).to eq("active")
      
      # Check second expression
      second_expr = form_data[:expressions][1]
      expect(second_expr[:property]).to eq("score")
      expect(second_expr[:operator]).to eq("gt")
      expect(second_expr[:value]).to eq("100")
    end
  end

  describe "integration with Feature decorator" do
    let(:feature) { Flipper::Feature.new(:test_feature, Flipper::Adapters::Memory.new) }

    it "provides form_data for feature with expression" do
      feature.enable_expression(simple_expression)
      decorator = described_class.new(feature.expression)
      form_data = decorator.form_data
      expect(form_data[:has_expression]).to be(true)
      expect(form_data[:type]).to eq("property")
    end

    it "provides form_data for feature without expression" do
      decorator = described_class.new(feature.expression)
      form_data = decorator.form_data
      expect(form_data[:has_expression]).to be(false)
      expect(form_data[:type]).to eq("property")
    end
  end
end
