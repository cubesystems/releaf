require "rails_helper"

describe Releaf::Builders::PaginationBuilder, type: :class do

  class PaginationTestView < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ PaginationTestView.new }

  let(:items_per_page) { 3 }
  let(:current_page_number) { 1 }
  let(:collection){ Book.page(current_page_number).per_page(items_per_page) }
  let(:params){ { search: "xxx"} }
  let(:subject){ described_class.new(template, collection: collection, params: params ) }

  before do |example|
    unless example.metadata[:stub_url_for] === false
      allow(template).to receive(:url_for) { |params| "http://example.com/?#{params.to_query}" }
    end
  end

  it "provides accessor for template given in constructor" do
    subject = described_class.new( :foo )
    expect( subject.template ).to eq :foo
  end

  it "provides accessor for collection given in constructor" do
    subject = described_class.new( nil, collection: :foo )
    expect( subject.collection ).to eq :foo
  end

  it "provides accessor for params given in constructor" do
    subject = described_class.new( nil, params: :foo )
    expect( subject.params ).to eq :foo
  end


  describe "#output" do

    context "when collection has no entries" do
      it "returns nil" do
        expect(subject.total_entries).to eq 0
        expect(subject).to_not receive(:pagination_block)
        expect(subject.output).to be nil
      end
    end

    context "when collection has less entries than allowed on one page" do
      before do
        FactoryGirl.create( :book )
      end

      it "returns nil" do
        expect(subject.total_entries).to eq 1
        expect(subject).to_not receive(:pagination_block)
        expect(subject.output).to be nil
      end
    end

    context "when collection has exactly the number of entries that fits on one page" do
      before do
        items_per_page.times do
          FactoryGirl.create( :book )
        end
      end

      it "returns nil" do
        expect(subject.total_entries).to eq 3
        expect(subject).to_not receive(:pagination_block)
        expect(subject.output).to be nil
      end
    end


    context "when collection has more than one page" do
      before do
        (items_per_page + 1).times do
          FactoryGirl.create( :book )
        end
      end

      it "returns #pagination_block" do
        expect(subject.total_entries).to eq 4
        expect(subject).to receive(:pagination_block).and_return('ok')
        expect(subject.output).to eq "ok"
      end
    end

  end

  describe "#pagination_block" do

    let(:current_page_number) { 2 }

    it "returns pagination parts wrapped in a container" do
      allow(subject).to receive(:pagination_parts).and_return [ "<strong>weak</strong>".html_safe, "<escape_me>" ]
      expect(subject.pagination_block).to match_html %Q[
          <div class="pagination">
              <strong>weak</strong>
              &lt;escape_me&gt;
          </div>
      ]
    end

    it "returns pagination buttons and select with options" do

      14.times do
        FactoryGirl.create :book
      end

      expect(subject.pagination_block).to match_html %Q[
        <div class="pagination">

          <a class="button only-icon secondary previous" title="Previous page" rel="prev" href="http://example.com/?page=1&amp;search=xxx">
            <i class="fa fa-chevron-left"></i>
          </a>

          <select name="page">
            <option value="1">1-3</option>
            <option value="2" selected="selected">4-6</option>
            <option value="3">7-9</option>
            <option value="4">10-12</option>
            <option value="5">13-14</option>
          </select>

          <a class="button only-icon secondary next" title="Next page" rel="next" href="http://example.com/?page=3&amp;search=xxx">
            <i class="fa fa-chevron-right"></i>
          </a>

        </div>
      ]

    end

  end


  describe "#pagination_parts" do
    it "returns an array with previous page button, page select and next page button" do
      allow(subject).to receive(:previous_page_button).and_return("previous")
      allow(subject).to receive(:next_page_button).and_return("next")
      allow(subject).to receive(:pagination_select).and_return("select")
      expect(subject.pagination_parts).to eq [ "previous", "select", "next" ]
    end
  end


  def previous_page_button
    page_button( -1, 'previous', 'chevron-left' )
  end

  def next_page_button
    page_button( 1, 'next', 'chevron-right' )
  end

  describe "#previous_page_button" do
    it "returns #page_button with -1 offset and appropriate class and icon names" do
      expect(subject).to receive(:page_button).with( -1, 'previous', 'chevron-left').and_return('ok')
      expect(subject.previous_page_button).to eq 'ok'
    end
  end

  describe "#next_page_button" do
    it "returns #page_button with +1 offset and appropriate class and icon names" do
      expect(subject).to receive(:page_button).with( 1, 'next', 'chevron-right').and_return('ok')
      expect(subject.next_page_button).to eq 'ok'
    end
  end

  describe "#page_button" do

    before do
      allow(subject).to receive(:t).with('Foo page', scope: 'pagination').and_return('Foo page label')
      allow(subject).to receive(:t).with('Bar page', scope: 'pagination').and_return('Bar page label')

    end

    context "when calculated relative page number is valid" do

      it "returns a button with correct class and rel attributes and a href pointing to the offset page" do

        5.times do
          FactoryGirl.create(:book)
        end

        expect(subject.page_button( 1, 'foo', 'foo-icon' )).to match_html %Q[
          <a class="button only-icon secondary foo" title="Foo page label" rel="next" href="http://example.com/?page=2&amp;search=xxx">
            <i class="fa fa-foo-icon"></i>
          </a>
        ]
      end

    end

    context "when the calculated relative page number is invalid" do

      it "returns a disabled button with correct class" do
        expect(subject.page_button( -1, 'bar', 'bar-icon' )).to match_html %Q[
          <button class="button only-icon secondary bar" title="Bar page label" type="button" autocomplete="off" disabled="disabled">
            <i class="fa fa-bar-icon"></i>
          </button>
        ]
      end

    end

  end


  describe "#page_numbers" do

    it "returns an array of integers from 1 to total number of pages" do
      allow(collection).to receive(:total_pages).and_return(12)
      expect(subject.page_numbers).to eq [1,2,3,4,5,6,7,8,9,10,11,12]
    end

  end


  describe "#relative_page_number" do

    before do
      allow(collection).to receive(:current_page).and_return(3)
      allow(collection).to receive(:total_pages).and_return(12)
    end

    context "when adding the offset to current page number" do
      context "results in a valid page number" do
        it "returns the page number" do
          expect(subject.relative_page_number(-1)).to eq 2
        end
      end

      context "results in a page number larger than the total number of pages" do
        it "returns nil" do
          expect(subject.relative_page_number(10)).to be nil
        end
      end

      context "results in a page number less than one" do
        it "returns nil" do
          expect(subject.relative_page_number(-3)).to be nil
        end
      end
    end

  end


  describe "#relative_page_relationship" do

    context "when given -1" do
      it "returns :prev" do
        expect(subject.relative_page_relationship(-1)).to eq :prev
      end
    end

    context "when given 1" do
      it "returns :next" do
        expect(subject.relative_page_relationship(1)).to eq :next
      end
    end

    [0, -2, 3, nil, true, false].each do |arg|
      context "when given #{arg.nil? ? 'nil' : arg.to_s}" do
        it "returns nil" do
          expect(subject.relative_page_relationship(arg)).to be nil
        end
      end
    end

  end

  describe "#page_url", stub_url_for: false do

    it "calls url_for on template with added page number param" do
      expect(template).to receive(:url_for).with( search: "xxx", page: 3).and_return("ok")
      expect(subject.page_url(3)).to eq "ok"
    end

  end

  describe "#pagination_select" do

    it "returns select tag with pagination options" do
      allow(subject).to receive(:pagination_options).and_return [ "<option>1-2</option>".html_safe, "<escape_me>" ]
      expect(subject.pagination_select).to match_html %Q[
          <select name="page">
              <option>1-2</option>
              &lt;escape_me&gt;
          </select>
      ]
    end

  end

  describe "#pagination_options" do

    let(:current_page_number) { 2 }

    it "returns an array with option tags for page select" do
      allow(subject).to receive(:page_numbers).and_return( [ 1, 2, 3 ] )
      allow(subject).to receive(:page_label) { |page_number| "page label #{page_number}" }
      expect(subject.pagination_options).to eq [
        '<option value="1">page label 1</option>',
        '<option value="2" selected="selected">page label 2</option>',
        '<option value="3">page label 3</option>'
      ]
    end

  end


  describe "#page_label" do

    before do
      14.times { FactoryGirl.create :book }
    end

    it "returns a string with the numbers of first and last items in page" do
      expect(subject.page_label(1)).to eq "1-3"
      expect(subject.page_label(5)).to eq "13-14"
    end
  end


end
