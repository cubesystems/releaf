require "spec_helper"

describe Releaf::Builder, type: :module do
  class FormBuilderTestHelper < ActionView::Base; end
  class BuilderIncluder
    include Releaf::Builder
    attr_accessor :template
  end

  let(:subject){ BuilderIncluder.new }
  let(:template){ FormBuilderTestHelper.new }

  describe "#resource_class_attributes" do
    it "returns resource columns and i18n attributes except ignorables" do
      allow(Book).to receive(:column_names).and_return(["a", "b", "c"])
      allow(subject).to receive(:resource_class_i18n_attributes).with(Book).and_return(["e", "d"])
      allow(subject).to receive(:resource_class_ignorable_attributes).with(Book).and_return(["b", "e"])

      expect(subject.resource_class_attributes(Book)).to eq(["a", "c", "d"])
    end
  end

  describe "#resource_class_ignorable_attributes" do
    it "returns array with default ignorable attributes" do
      list = ["id", "created_at", "updated_at", "password", "password_confirmation", "encrypted_password", "item_position"]
      expect(subject.resource_class_ignorable_attributes(Book)).to eq(list)
    end
  end

  describe "#resource_class_i18n_attributes" do
    context "when given resource class have i18n attributes" do
      it "returns array with i18n attributes" do
        expect(subject.resource_class_i18n_attributes(Book)).to eq(["description"])
      end
    end

    context "when given resource class don't have i18n attributes" do
      it "returns empty array" do
        expect(subject.resource_class_i18n_attributes(Author)).to eq([])
      end
    end
  end

  describe "#controller" do
    it "returns template contoller" do
      allow(template).to receive(:controller).and_return("x")
      subject.template = template
      expect(subject.controller).to eq("x")
    end
  end

  describe "#tag" do
    before do
      subject.template = template
    end

    context "when block is not given" do
      context "when passing string as content" do
        let(:output) do
          subject.tag(:span, "<p>x</p>", class: "red")
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer

        end

        it "passes all arguments to template #content_tag method and returns properly escaped result" do
          expect( output ).to eq('<span class="red">&lt;p&gt;x&lt;/p&gt;</span>')
        end
      end

      context "when passing safe buffer as content" do
        let(:output) do
          subject.tag(:span, ActiveSupport::SafeBuffer.new("<p>x</p>"), class: "red")
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer

        end

        it "passes all arguments to template #content_tag method and returns properly escaped result" do
          expect( output ).to eq('<span class="red"><p>x</p></span>')
        end
      end

    end

    context "when block is given" do
      context "when block evaluates to array" do
        let(:content) do
          [
            '<p>foo</p>',
            'bar',
            ActiveSupport::SafeBuffer.new('<p>baz</p>')
          ]
        end

        let(:output) do
          subject.tag(:div, class: 'important') { content }
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer
        end

        it "safely joins array" do
          expect( template ).to receive(:safe_join).with(content).and_call_original
          output
        end

        it "passes joined result to #template#content_tag as content" do
          allow( template ).to receive(:safe_join).with(content).and_return('super duper')
          expect( output ).to eq('<div class="important">super duper</div>')
        end

        it "returns properly escaped result" do
          expect( output ).to eq('<div class="important">&lt;p&gt;foo&lt;/p&gt;bar<p>baz</p></div>')
        end

      end

      context "when block evaluates to safe buffer" do
        let(:output) do
          subject.tag(:div, class: 'important') { ActiveSupport::SafeBuffer.new('<p>content</p>') }
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer
        end

        it "doesn't call #template#safe_join" do
          expect( template ).to_not receive(:safe_join)
          output
        end

        it "passes block result to #template#content_tag as content which won't be escaped" do
          expect( output ).to eq '<div class="important"><p>content</p></div>'
        end
      end

      context "when block evaluates to string" do
        let(:output) do
          subject.tag(:div, class: 'important') { '<p>content</p>' }
        end

        it "returns an instance of ActiveSupport::SafeBuffer" do
          expect( output ).to be_a ActiveSupport::SafeBuffer
        end

        it "doesn't call #template#safe_join" do
          expect( template ).to_not receive(:safe_join)
          output
        end

        it "passes block result to #template#content_tag as content which will be escaped" do
          expect( output ).to eq '<div class="important">&lt;p&gt;content&lt;/p&gt;</div>'
        end
      end
    end
  end # describe "#tag"

  describe "#safe_join" do
    before do
      subject.template = template
    end

    let(:content) do
      ['foo', '<p>bar</p>', ActiveSupport::SafeBuffer.new('<p>baz</p>')]
    end

    let(:output) do
      subject.safe_join { content }
    end

    it "returns an instance of ActiveSupport::SafeBuffer" do
      expect( output ).to be_a ActiveSupport::SafeBuffer
    end

    it "passes block result to #template#safe_join" do
      expect( template ).to receive(:safe_join).with(content).and_call_original
      output
    end

    it "returns correctly escaped result" do
      expect( output ).to eq 'foo&lt;p&gt;bar&lt;/p&gt;<p>baz</p>'
    end
  end

end
