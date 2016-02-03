require "rails_helper"

describe Releaf::Application do
  describe "#configure" do
    it "assigns new configuration instance, evaluate block, initialize locales and components" do
      configuration = Releaf::Configuration.new
      allow(Releaf::Configuration).to receive(:new).and_return(configuration)

      expect(subject).to receive(:config=).with(configuration).and_call_original.ordered
      expect(configuration).to receive(:menu=).with("x").ordered
      expect(configuration).to receive(:initialize_locales).ordered
      expect(configuration).to receive(:initialize_components).ordered
      subject.configure{ config.menu = "x" }
    end
  end

  describe "#render_layout" do
    before do
      class DummyBuilder
        def initialize(x)
        end

        def output(&block)
          yield
        end
      end

      subject.config = Releaf::Configuration.new
      allow(subject.config).to receive(:layout_builder_class_name).and_return("DummyBuilder")
      builder = DummyBuilder.new("xx")
      allow(DummyBuilder).to receive(:new).with("tmpl").and_return(builder)
    end

    it "returns layout builder rendered layout" do
      expect(subject.render_layout("tmpl"){ "pp" }).to eq("pp")
    end

    it "returns html safe content" do
      expect(subject.render_layout("tmpl"){ "pp" }.html_safe?).to be true
    end
  end
end

