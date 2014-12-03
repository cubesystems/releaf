shared_examples "a SerializedArrayParamsNormalizer includer" do |args|
  describe "before filter" do
    describe Releaf::Permissions::RolesController do # TODO: rewrite to anonymous controller test
      it "normalizes empty array params" do
        sign_in FactoryGirl.create(:user)
        resource = create(:content_role)
        expect{ patch :update, id: resource.id, resource: {name: "x", permissions: ["x"]} }
          .to change{ resource.reload.permissions }.to(["x"])

        expect{ patch :update, id: resource.id, resource: {name: "xa"} }
          .to change{ resource.reload.permissions }.to([])
      end
    end
  end

  describe "#normalize_serialized_array_params" do
    it "normalizes all empty, normalizable resource array params" do
      allow(subject).to receive(:params).and_return(resource: {"colors" => ["x"], "title" => "asd"})
      allow(subject).to receive(:normalizable_resource_array_params).and_return(["permissions", "colors"])
      subject.normalize_serialized_array_params
      expect(subject.params).to eq(resource: {"colors" => ["x"], "title" => "asd", "permissions" => []})
    end
  end

  describe "#normalizable_resource_array_params" do
    it "returns array with normalizable array param keys based on current resource params" do
      allow(subject).to receive(:resource_array_params).and_return(["permissions", "colors"])
      allow(subject).to receive(:resource_class).and_return(Releaf::Permissions::Role)
      expect(subject.normalizable_resource_array_params).to eq(["permissions"])
    end
  end

  describe "#resource_array_params" do
    it "returns array with valid array resource parameters keys as strings" do
      allow(subject).to receive(:resource_params).and_return([:title, {sizes: []}, :weight, {colors: []}])
      expect(subject.resource_array_params).to eq(["sizes", "colors"])

      allow(subject).to receive(:resource_params).and_return([:title, {sizes: ["a"]}, :weight, {colors: [], assad: []}])
      expect(subject.resource_array_params).to eq([])
    end
  end

  describe "#normalize_serialized_array_params?" do
    before do
      allow(subject).to receive(:mass_assigment_action?).and_return(true)
      allow(subject.resource_class).to receive(:serialized_attributes?).and_return(true)
    end

    context "when mass assigmend action and resource class has serialized attributes" do
      it "returns true" do
        expect(subject.normalize_serialized_array_params?).to be true
      end
    end

    context "when no mass assigmend action and resource class has serialized attributes" do
      it "returns false" do
        allow(subject).to receive(:mass_assigment_action?).and_return(false)
        expect(subject.normalize_serialized_array_params?).to be false
      end
    end

    context "when mass assigmend action and resource class has no serialized attributes" do
      it "returns false" do
        allow(subject.resource_class).to receive(:serialized_attributes?).and_return(false)
        expect(subject.normalize_serialized_array_params?).to be false
      end
    end
  end
end
