require "spec_helper"

describe Releaf::Content::Nodes::ToolboxBuilder, type: :class do

  class NodeToolboxBuilderTestHelper < ActionView::Base
    include Releaf::ButtonHelper
    include Releaf::ApplicationHelper
  end

  let(:template){ NodeToolboxBuilderTestHelper.new }
  subject { described_class.new(template) }

  let(:node){ Node.new(content_type: "TextPage", slug: "a", id: 99) }

  before do
    allow(subject).to receive(:resource).and_return(node)
    allow(subject).to receive(:destroy_confirmation_link).and_return(:super_item)
    allow(subject).to receive(:feature_available?).with(:destroy).and_return true
  end

  it "extends Releaf::Builders::ToolboxBuilder" do
    expect(described_class.ancestors).to include Releaf::Builders::ToolboxBuilder
  end

  describe "#items" do

    before do
      allow(subject).to receive(:params).and_return({})
      allow(subject).to receive(:add_child_button).and_return( :add_child_item )
      allow(subject).to receive(:go_to_button).and_return( :go_to_item )
      allow(subject).to receive(:copy_button).and_return( :copy_item )
      allow(subject).to receive(:move_button).and_return( :move_item )
    end

    context "when applied to a new record" do

      it "returns only items returned by parent class" do
        allow(node).to receive(:new_record?).and_return true
        expect(subject.items).to eq([ :super_item ])
      end

    end

    context "when applied to an existing record" do

      before do
        allow(node).to receive(:new_record?).and_return false
      end

      it "prepends add child, go to, copy and move items to the list returned by parent class" do
        expect(subject.items).to eq([ :add_child_item, :go_to_item, :copy_item, :move_item, :super_item ])
      end

      context "when in index context" do

        it "does not include go_to_item" do
          allow(subject).to receive(:params).and_return({ context: "index" })
          expect(subject.items).to eq([ :add_child_item, :copy_item, :move_item, :super_item ])
        end
      end

    end

  end

  describe "item methods" do

    describe "#add_child_button" do
      it "returns an ajaxbox link to content type dialog" do
        allow(subject).to receive(:t).with('Add child').and_return('addchildxx')
        allow(subject).to receive(:url_for).with(action: 'content_type_dialog', parent_id: 99).and_return('dialogurl')
        html = '<a class="button ajaxbox" title="addchildxx" href="dialogurl">addchildxx</a>'
        expect(subject.add_child_button).to eq(html)
      end
    end

    describe "#go_to_button" do
      it "returns an ajaxbox link to go to dialog" do
        allow(subject).to receive(:t).with('Go to').and_return('gotoxx')
        allow(subject).to receive(:url_for).with(action: 'go_to_dialog').and_return('dialogurl')
        html = '<a class="button ajaxbox" title="gotoxx" href="dialogurl">gotoxx</a>'
        expect(subject.go_to_button).to eq(html)
      end
    end


    describe "#copy_button" do
      it "returns an ajaxbox link to copy dialog" do
        allow(subject).to receive(:t).with('Copy').and_return('copyxx')
        allow(subject).to receive(:url_for).with(action: 'copy_dialog', id: 99).and_return('dialogurl')
        html = '<a class="button ajaxbox" title="copyxx" href="dialogurl">copyxx</a>'
        expect(subject.copy_button).to eq(html)
      end
    end


    describe "#move_button" do
      it "returns an ajaxbox link to move dialog" do
        allow(subject).to receive(:t).with('Move').and_return('movexx')
        allow(subject).to receive(:url_for).with(action: 'move_dialog', id: 99).and_return('dialogurl')
        html = '<a class="button ajaxbox" title="movexx" href="dialogurl">movexx</a>'
        expect(subject.move_button).to eq(html)
      end
    end

  end

end