require "rails_helper"

describe Releaf::Content::Node::Copy do

  let(:root_node) { create(:home_page_node) }

  let(:node) { create(node_factory, parent: root_node) }
  let(:node_factory) { :text_page_node }

  let(:content_factory) { :text_page }
  let(:content_attributes) { { } }

  let(:complex_node_factory) { :banner_page_node }
  let(:complex_content_factory) { :banner_page }
  let(:complex_content_duplicatable_associations) {
  [
    {
      banner_groups: [
        { banners: [] }
      ]
    }
  ] }

  let(:file) { File.new(File.expand_path('../../../../fixtures/dummy.png', __dir__)) }

  let(:original) { create(content_factory, content_attributes) }

  describe "#call" do
    subject { described_class.new(node: node, parent_id: root_node.id ) }

    it "returns node" do
      expect(subject.call.class).to eq(node.class)
    end
  end

  describe "#make_copy" do
    # this is a double check to verify file duplication by doing the full copying process.
    # #duplicate_dragonfly_attachments is tested separately in more detail below
    subject { described_class.new(node: node, parent_id: root_node.id ) }

    context "when node content has dragonfly file fields" do
      let(:node_factory) { complex_node_factory }

      it "duplicates dragonfly attachments, storing them as separate files that are no longer linked" do
        node.content.top_banner = file
        node.save!
        copy = subject.make_copy

        # make sure the uids are non-empty and different
        expect(node.content.top_banner_uid).to be_present
        expect(copy.content.top_banner_uid).to be_present
        expect(copy.content.top_banner_uid).to_not eq node.content.top_banner_uid

        # make sure the files are stored and exist
        expect(copy.content.top_banner.path).to start_with Dragonfly.app.datastore.root_path
        expect(node.content.top_banner.path).to start_with Dragonfly.app.datastore.root_path
        expect(copy.content.top_banner.path).to_not eq node.content.top_banner.path
      end
    end

  end


  describe "#duplicate_under" do
    let!(:source_node) { create(:node, locale: "lv") }
    let!(:target_node) { create(:node, locale: "en") }

    before do
      allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
      subject.node = source_node
      subject.parent_id = target_node.id
    end

    it "creates duplicated node under target node" do
      new_node = Node.new
      duplicated_content = double('content', id: 1234)
      expect( Node ).to receive(:new).ordered.and_return(new_node)
      expect( new_node ).to receive(:assign_attributes_from).with(source_node).ordered.and_call_original
      expect( subject ).to receive(:duplicate_content).ordered.and_return(duplicated_content)
      expect( new_node ).to receive(:content_id=).with(1234).ordered
      expect( Releaf::Content::Node::SaveUnderParent ).to receive(:call).with(node: new_node, parent_id: target_node.id)
        .ordered.and_call_original
      expect(subject.duplicate_under).to eq(new_node)
    end

    it "doesn't update settings timestamp" do
      expect( Node ).to_not receive(:updated)
      subject.duplicate_under
    end
  end


  describe "#duplicate_content" do

    let(:content) { node.content }

    before do
      allow(subject).to receive(:node).and_return(node)
    end

    context "when node has a content object" do

      it "calls #duplicate_object with current content" do
        expect(subject).to receive(:duplicate_object).with(content).and_return(content)
        subject.duplicate_content
      end

      it "saves the duplicated result" do
        new_content = subject.duplicate_content
        expect(new_content.new_record?).to be false
      end

      it "returns the newly saved content" do
        new_content = subject.duplicate_content
        expect(new_content.id).to_not eq content.id
      end
    end

    context "when node does not have a content object" do
      before do
        node.content = nil
      end

      it "does nothing" do
        expect(subject).to_not receive(:duplicate_object)
        expect(node).to_not receive(:save!)
        subject.duplicate_content
      end
      it "returns nil" do
        expect(subject.duplicate_content).to be_nil
      end
    end

  end


  describe "#duplicate_object" do

    context "when object has no duplicatable associations" do
      let(:content_factory) { :text_page }
      let(:content_attributes) { { text_html: "html" } }

      it "builds an unsaved copy of the object" do
        copy = subject.duplicate_object(original)
        expect(copy.class).to be original.class
        expect(copy.new_record?).to be true

        expect(copy.text_html).to eq original.text_html
      end

      it "uses #deep_clone for copying" do
        expect(subject).to receive(:duplicatable_associations).with(original.class).and_call_original
        expect(original).to receive(:deep_clone).with( include: [] ).and_call_original
        subject.duplicate_object(original)
      end

      it "calls #supplement_object_duplication with the original object and its new copy" do
        copy = original.dup

        # stub #dup (which is called by deep_clone internally) so that it returns a known instance
        allow(original).to receive(:dup).and_return(copy)

        expect(subject).to receive(:supplement_object_duplication).with(original, copy)
        subject.duplicate_object(original)
      end

    end

    context "when object has duplicatable associations" do
      let(:content_factory) { complex_content_factory }

      let(:content_attributes) do
        {
          intro_text_html: "Intro html",
          banner_groups_attributes: [
            {
              title: "Group title",
              banners_attributes: [
                url: "Banner url"
              ]
            },
          ]
        }
      end

      it "passes duplicatable associations to #deep_clone" do
        expect(original).to receive(:deep_clone).with( include: complex_content_duplicatable_associations ).and_call_original
        subject.duplicate_object(original)
      end

      it "builds an unsaved copy with nested copies of associated objects" do
        copy = subject.duplicate_object(original)
        expect(copy.class).to be original.class
        expect(copy.new_record?).to be true
        expect(copy.intro_text_html).to eq original.intro_text_html

        original_item = original.banner_groups.first
        copied_item   = copy.banner_groups.first
        expect(copied_item.class).to be original_item.class
        expect(copied_item.new_record?).to be true
        expect(copied_item.title).to eq original_item.title

        original_nested_item  = original.banner_groups.first.banners.first
        copied_nested_item    = copy.banner_groups.first.banners.first
        expect(copied_nested_item.class).to be original_nested_item.class
        expect(copied_nested_item.new_record?).to be true
        expect(copied_nested_item.url).to eq original_nested_item.url
      end

      it "calls #supplement_object_duplication on all cloned objects" do
        original_item         = original.banner_groups.first
        original_nested_item  = original_item.banners.first

        expect(subject).to receive(:supplement_object_duplication).with(original, kind_of(original.class))
        expect(subject).to receive(:supplement_object_duplication).with(original_item, kind_of(original_item.class))
        expect(subject).to receive(:supplement_object_duplication).with(original_nested_item, kind_of(original_nested_item.class))
        subject.duplicate_object(original)
      end

    end

  end

  describe "#supplement_object_duplication" do
    it "calls #duplicate_dragonfly_attachments with given original and copy" do
      expect(subject).to receive(:duplicate_dragonfly_attachments).with(:foo, :bar)
      subject.supplement_object_duplication(:foo, :bar)
    end
  end

  describe "#duplicatable_associations" do
    let(:content_class) { build(content_factory).class }

    it "uses Releaf::ResourceBase to detect duplicatable associations" do
      expect(Releaf::ResourceBase).to receive(:new).with(content_class).and_call_original
      subject.duplicatable_associations(content_class)
    end

    context "when given class has duplicatable associations" do
      it "returns duplicatable association names as nested arrays of hashes" do
        expect(subject.duplicatable_associations(content_class)).to eq []
      end
    end

    context "when given class has no duplicatable associations" do
      let(:content_factory) { complex_content_factory }
      it "returns an empty array" do
        expect(subject.duplicatable_associations(content_class)).to eq complex_content_duplicatable_associations
      end
    end
  end


  describe "#duplicate_dragonfly_attachments" do
    let(:content_factory) { complex_content_factory }
    let(:copy) { original.dup }

    context "when the original object's dragonfly attributes" do

      context "are blank" do
        it "sets the file attributes to nil on the given copy" do
          expect(copy).to receive(:top_banner_uid=).with(nil).ordered
          expect(copy).to receive(:top_banner=).with(nil).ordered
          subject.duplicate_dragonfly_attachments(original, copy)
        end
      end

      context "contain files" do

        it "separates the attachments so that dragonfly treats them as separate files" do
          # it is important that the owner class used in this test has at least two dragonfly attributes
          # and the test is not using the first one.
          # (an earlier implementation worked only with the first file
          # and would have passed the test if the test used the first file)
          expect(original.dragonfly_attachments.keys.find_index(:bottom_banner)).to be > 0

          original.bottom_banner = file
          original.save!

          subject.duplicate_dragonfly_attachments(original, copy)
          copy.save!

          # refetch the objects. calling #reload on them is not enough
          original_id = original.id
          copy_id     = copy.id
          klass       = original.class

          original = klass.find(original_id)
          copy     = klass.find(copy_id)

          # make sure the uids are non-empty and different
          expect(original.bottom_banner_uid).to be_present
          expect(copy.bottom_banner_uid).to be_present
          expect(copy.bottom_banner_uid).to_not eq original.bottom_banner_uid

          # make sure the files are stored and exist
          expect(copy.bottom_banner.path).to start_with Dragonfly.app.datastore.root_path
          expect(original.bottom_banner.path).to start_with Dragonfly.app.datastore.root_path
          expect(copy.bottom_banner.path).to_not eq original.bottom_banner.path

          # make sure the metadata is readable as well
          expect(copy.bottom_banner.format).to eq original.bottom_banner.format
        end

      end

      context "contain files that are missing" do

        it "sets the file attributes to nil on the given copy" do
          original.top_banner = file
          original.save!

          original_id = original.id

          # simulate deletion from filesystem by setting the uid to an invalid path
          original.top_banner_uid = "xxx" + original.top_banner_uid
          original.save!

          klass = original.class
          original = klass.find(original_id)

          subject.duplicate_dragonfly_attachments(original, copy)
          copy.save!
          copy_id = copy.id
          copy = klass.find(copy_id)

          expect(copy.top_banner_uid).to be_nil
          expect(copy.top_banner).to be_nil
        end

      end

    end
  end



end
