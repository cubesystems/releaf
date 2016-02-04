require "rails_helper"

describe Releaf::ResourceUtilities do
  let(:resource){ Releaf::Permissions::Role.new }
  let(:users_association){ resource.class.reflect_on_association(:users) }
  let(:permissions_association){ resource.class.reflect_on_association(:permissions) }

  describe ".restricted_associations" do
    it "returns hash with restricted association objects and controller" do
      allow(described_class).to receive(:restricted_associations).with(resource).and_return([permissions_association, users_association])
      allow(described_class).to receive(:association_controller).with(users_association).and_return("aa")
      allow(described_class).to receive(:association_controller).with(permissions_association).and_return("bb")
      resource.users.build
      resource.permissions.build

      expect(described_class.restricted_relations(resource)).to eq(
        users: {objects: resource.users, controller: "aa"},
        permissions: {objects: resource.permissions, controller: "bb"},
      )
    end
  end

  describe ".association_controller" do
    it "returns guessed controller from given association name" do
      expect(described_class.association_controller(users_association)).to eq("users")
    end

    context "when no controller guessed" do
      it "returns nil" do
        expect(described_class.association_controller(permissions_association)).to be nil
      end
    end
  end

  describe ".restricted_associations" do
    it "returns array with restricted associations" do
      allow(described_class).to receive(:restricted_association?).with(resource, users_association).and_return(false)
      allow(described_class).to receive(:restricted_association?).with(resource, permissions_association).and_return(true)
      expect(described_class.restricted_associations(resource)).to eq([permissions_association])
    end
  end

  describe ".restricted_association?" do
    context "when associations with dependent option `restrict_with_exception` given" do
      let(:association){ resource.class.reflect_on_association(:users) }

      context "when association object(-s) exists" do
        it "returns true" do
          resource.users.build
          users = resource.users
          allow(resource).to receive(:users).and_return(users)
          allow(users).to receive(:exists?).and_return(true)
          expect(described_class.restricted_association?(resource, association)).to be true
        end
      end

      context "when association object(-s) does not exist" do
        it "returns false" do
          expect(described_class.restricted_association?(resource, association)).to be false
        end
      end
    end

    context "when associations with dependent option other than `restrict_with_exception` given" do
      it "returns false" do
        association = resource.class.reflect_on_association(:permissions)
        expect(described_class.restricted_association?(resource, association)).to be false
      end
    end
  end

  describe ".destroyable?" do
    context "when no restricted association" do
      it "returns true" do
        allow(described_class).to receive(:restricted_associations).with(resource).and_return([])
        expect(described_class.destroyable?(resource)).to be true
      end
    end

    context "when restricted association exist" do
      it "returns false" do
        allow(described_class).to receive(:restricted_associations).with(resource).and_return([:a])
        expect(described_class.destroyable?(resource)).to be false
      end
    end
  end
end
