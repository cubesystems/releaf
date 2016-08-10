require "rails_helper"

describe Releaf::Builders::ResourceView, type: :class do
  class ResourceViewIncluder
    include Releaf::Builders::ResourceView
  end

  class ResourceViewTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  let(:described_class){ ResourceViewIncluder }
  let(:template){ ResourceViewTestHelper.new }
  let(:subject){ described_class.new(template) }
  let(:controller){ Releaf::ActionController.new }
  let(:resource){ Book.new }

  before do
    allow(template).to receive(:controller).and_return(controller)
    allow(subject).to receive(:resource).and_return(resource)
    allow(subject).to receive(:index_path).and_return("_index_path_")
  end

  it "includes Releaf::Builders::View" do
    expect(described_class.ancestors).to include(Releaf::Builders::View)
  end

  it "includes Releaf::Builders::Resource" do
    expect(described_class.ancestors).to include(Releaf::Builders::Resource)
  end

  it "includes Releaf::Builders::Toolbox" do
    expect(described_class.ancestors).to include(Releaf::Builders::Toolbox)
  end

  describe "#section" do
    before do
      allow(subject).to receive(:section_attributes).and_return(a: "b")
      allow(subject).to receive(:section_blocks).and_return(["_section_","_blocks_"])
    end

    it "returns section with index url preserver and section blocks" do
      expect(subject.section).to eq('<section a="b">_section__blocks_</section>')
    end
  end

  describe "#section_header_text" do
    before do
      allow(subject).to receive(:t).with("Create new resource").and_return("newww")
      allow(subject).to receive(:resource_title).with(resource).and_return("existng")
    end

    context "when resource is new object" do
      it "returns resource to text cast result" do
        expect(subject.section_header_text).to eq("newww")
      end
    end

    context "when resource is persisted object" do
      it "returns resource to text cast result" do
        allow(resource).to receive(:new_record?).and_return(false)
        expect(subject.section_header_text).to eq("existng")
      end
    end
  end

  describe "#section_header_extras" do
    before do
      allow(subject).to receive(:toolbox).with(resource, index_path: "_index_path_").and_return("_tlbx_")
      allow(subject).to receive(:feature_available?).with(:toolbox).and_return(true)
    end

    it "returns header extras with toolbox button" do
      expect(subject.section_header_extras).to eq('<div class="extras toolbox-wrap">_tlbx_</div>')
    end

    context "when toolbox feature is not available" do
      it "returns nil" do
        allow(subject).to receive(:feature_available?).with(:toolbox).and_return(false)
        expect(subject.section_header_extras).to be nil
      end
    end
  end

  describe "#section_body" do
    it "returns section body block with applied section body attributes" do
      allow(subject).to receive(:section_body_blocks).and_return(["a", "b"])
      allow(subject).to receive(:section_body_attributes).and_return(class: "x")
      expect(subject.section_body).to eq('<div class="x">ab</div>')
    end
  end

  describe "#section_body_attributes" do
    it "returns section hash with body class" do
      expect(subject.section_body_attributes).to eq(class: ["body"])
    end
  end

  describe "#section_body_blocks" do
    it "returns empty array" do
      expect(subject.section_body_blocks).to eq([])
    end
  end

  describe "#footer_secondary_tools" do
    before do
      allow(subject).to receive(:back_to_list_button).and_return("_btn_")
      allow(subject).to receive(:back_to_list?).and_return(true)
    end

    it "returns array with back to list button" do
      expect(subject.footer_secondary_tools).to eq(["_btn_"])
    end

    context "when toolbox feature is not available" do
      it "returns empty array" do
        allow(subject).to receive(:back_to_list?).and_return(false)
        expect(subject.footer_secondary_tools).to eq([])
      end
    end
  end

  describe "#back_to_list?" do
    before do
      allow(subject).to receive(:params).and_return(index_path: "xxx")
      allow(subject).to receive(:feature_available?).with(:index).and_return(true)
    end

    context "when index feature is available and index_path is present within params" do
      it "returns true" do
        expect(subject.back_to_list?).to be true
      end
    end

    context "when index_path is not present within params" do
      it "returns false" do
        allow(subject).to receive(:params).and_return(search: "xxx")
        expect(subject.back_to_list?).to be false
      end
    end

    context "when index feature is not available" do
      it "returns false" do
        allow(subject).to receive(:feature_available?).with(:index).and_return(false)
        expect(subject.back_to_list?).to be false
      end
    end
  end

  describe "#back_to_list_button" do
    it "returns `back to list` button" do
      allow(subject).to receive(:button)
        .with("to_list", "caret-left", {class: "secondary", href: "_index_path_"}).and_return("_btn_")
      allow(subject).to receive(:t).with("Back to list").and_return("to_list")
      expect(subject.back_to_list_button).to eq("_btn_")
    end
  end
end
