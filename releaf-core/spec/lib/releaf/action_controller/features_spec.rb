require 'rails_helper'

describe Releaf::ActionController::Features do
  let(:subject){ DummyActionControllerFeaturesIncluder.new }

  class DummyActionControllerFeaturesIncluder < Releaf::ActionController
    include Releaf::ActionController::Features
    include Releaf::Responders
    def params
      {action: "some_action"}
    end
  end

  describe "#verify_feature_availability!" do
    before do
      allow(subject).to receive(:action_feature).with("some_action").and_return(:feature_name)
    end

    it "adds itself to before filters" do
      before_actions = subject._process_action_callbacks.select{|f| f.kind == :before}.map{|f| f.filter }
      expect(before_actions).to include(:verify_controller_access!)
    end

    context "when no feature defined for action" do
      it "doesn no raise `Releaf::FeatureDisabled` exception" do
        allow(subject).to receive(:action_feature).with("some_action").and_return(nil)
        expect{ subject.verify_feature_availability! }.to_not raise_error
      end
    end

    context "when current feature is available" do
      it "doesn no raise `Releaf::FeatureDisabled` exception" do
        allow(subject).to receive(:feature_available?).with(:feature_name).and_return(true)
        expect{ subject.verify_feature_availability! }.to_not raise_error
      end
    end

    context "when current feature is not available" do
      it "raises `Releaf::FeatureDisabled` exception with stringified feature name" do
        allow(subject).to receive(:feature_available?).with(:feature_name).and_return(false)
        expect{ subject.verify_feature_availability! }.to raise_error(Releaf::FeatureDisabled, "feature_name")
      end
    end
  end

  describe "#action_feature" do
    before do
      allow(subject).to receive(:action_features).and_return(create: "xxx", te: "kkk")
    end

    it "returns matching feature for given action from action features" do
      expect(subject.action_feature(:create)).to eq("xxx")
    end

    it "symbolize given action name" do
      expect(subject.action_feature("te")).to eq("kkk")
    end
  end

  describe "#features" do
    it "returns array instance" do
      expect(subject.features).to be_instance_of Array
    end

    it "returned array contains features as symbols" do
      subject.features.each do|feature_name|
        expect(feature_name).to be_instance_of Symbol
      end
    end
  end

  describe "#action_features" do
    it "returns instance of `Hash`" do
      expect(subject.action_features).to be_instance_of(Hash)
    end

    it "returns hash with action and feature mapp as symbols" do
      subject.action_features.each_pair do|action_name, feature_name|
        expect(action_name).to be_instance_of(Symbol)
        expect(feature_name).to be_instance_of(Symbol)
      end
    end

    context "when `show` feature is available" do
      it "returns show to show feature mapping" do
        allow(subject).to receive(:feature_available?).with(:show).and_return(true)
        expect(subject.action_features[:show]).to eq(:show)
      end
    end

    context "when `show` feature is not available" do
      it "returns show to edit feature mapping" do
        allow(subject).to receive(:feature_available?).with(:show).and_return(false)
        expect(subject.action_features[:show]).to eq(:edit)
      end
    end
  end

  describe "#feature_disabled" do
    before do
      allow(subject).to receive(:action_responder).with(:feature_disabled).and_return("_res")
    end

    it "adds itself as rescue handler from `Releaf::FeatureDisabled` exception" do
      expect(Hash[subject.rescue_handlers]["Releaf::FeatureDisabled"]).to eq(:feature_disabled)
    end

    it "calls disabled feature responder" do
      expect(subject).to receive(:respond_with).with(nil, responder: "_res")
      subject.feature_disabled(Releaf::FeatureDisabled.new("xx"))
    end

    it "assigns @feature instance variable from exception message" do
      allow(subject).to receive(:respond_with)
      expect{ subject.feature_disabled(Releaf::FeatureDisabled.new("xx")) }.to change{ subject.instance_variable_get(:@feature) }
        .to("xx")
    end
  end

  describe "#feature_available?" do
    it "adds itself as helper" do
      expect(subject._helper_methods).to include(:feature_available?)
    end

    it "returns whether feature is defined within features variable" do
      allow(subject).to receive(:features).and_return([:edit])
      expect(subject.feature_available?(:create)).to be false

      allow(subject).to receive(:features).and_return([:edit, :create])
      expect(subject.feature_available?(:create)).to be true
    end

    context "when `search` feature requested" do
      it "also checks whether `index` feature is enabled" do
        allow(subject).to receive(:feature_available?).with(:search).and_call_original
        allow(subject).to receive(:feature_available?).with(:index).and_return(false)

        allow(subject).to receive(:features).and_return([:edit])
        expect(subject.feature_available?(:search)).to be false

        allow(subject).to receive(:features).and_return([:edit, :search])
        expect(subject.feature_available?(:search)).to be false

        allow(subject).to receive(:feature_available?).with(:index).and_return(true)
        expect(subject.feature_available?(:search)).to be true

        allow(subject).to receive(:features).and_return([:edit])
        expect(subject.feature_available?(:search)).to be false
      end
    end

    context "when `create_another` feature requested" do
      it "also checks whether `create` feature is enabled" do
        allow(subject).to receive(:feature_available?).with(:create_another).and_call_original
        allow(subject).to receive(:feature_available?).with(:create).and_return(false)

        allow(subject).to receive(:features).and_return([:edit])
        expect(subject.feature_available?(:create_another)).to be false

        allow(subject).to receive(:features).and_return([:edit, :create_another])
        expect(subject.feature_available?(:create_another)).to be false

        allow(subject).to receive(:feature_available?).with(:create).and_return(true)
        expect(subject.feature_available?(:create_another)).to be true

        allow(subject).to receive(:features).and_return([:edit])
        expect(subject.feature_available?(:create_another)).to be false
      end
    end
  end
end
