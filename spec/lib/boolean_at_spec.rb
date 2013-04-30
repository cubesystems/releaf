# encoding: UTF-8

require "spec_helper"

describe Book do
  # Book model requires Releaf::BooleanAt module
  # It then uses boolean_at :published_at

  describe Releaf::BooleanAt do
    describe ".boolean_at" do
      context ":published_at" do
        it "creates Book.published" do
          Book.respond_to?(:published).should be_true
        end

        it "creates Book.unpublished" do
          Book.respond_to?(:unpublished).should be_true
        end

        it "creates Book#published" do
          Book.new.respond_to?(:published).should be_true
        end

        it "creates Book#published?" do
          Book.new.respond_to?(:published?).should be_true
        end

        it "creates Book#published=" do
          Book.new.respond_to?(:published=).should be_true
        end
      end
    end
  end

  context "Class methods" do
    before do
      @book1 = FactoryGirl.create(:book, :title => 'published book', :published_at => Time.new)
      @book2 = FactoryGirl.create(:book, :title => 'published book')
    end

    describe ".published" do
      it "returns published books" do
        published_books = Book.published
        published_books.should     include(@book1)
        published_books.should_not include(@book2)

        @book1.published_at.should_not    be_nil
        @book2.published_at.should        be_nil
      end
    end

    describe ".unpublished" do
      it "returns unpublished books" do
        unpublished_books = Book.unpublished

        unpublished_books.should     include(@book2)
        unpublished_books.should_not include(@book1)

        @book1.published_at.should_not  be_nil
        @book2.published_at.should      be_nil
      end
    end
  end

  context "Instance methods" do
    before do
      @book1 = FactoryGirl.create(:book, :title => 'published book', :published_at => Time.new)
      @book2 = FactoryGirl.create(:book, :title => 'published book')
    end

    # #published? is an alias to #published
    describe "#published" do
      context "when book is publised" do
        it "return true" do
          @book1.published.should be_true
        end
      end

      context "when book is unpublished" do
        it "return false" do
          @book2.published.should be_false
        end
      end
    end

    describe "#published=" do
      context "when book is not published" do
        context "when setting to true" do
          it "sets published_at" do
            expect { @book2.published = true }.to change { @book2.published_at }.from(nil)
          end

          it "sets publised to true" do
            expect { @book2.published = true }.to change { @book2.published }.from(false).to(true)
          end
        end

        context "when setting to false" do
          it "doen't change published_at" do
            expect { @book2.published = false }.to_not change { @book2.published_at }
          end

          it "doen't change published" do
            expect { @book2.published = false }.to_not change { @book2.published }
          end
        end
      end

      context "when book is published" do
        context "when setting to true" do
          it "doesn't change published_at" do
            expect { @book1.published = true }.to_not change { @book1.published_at }
          end

          it "doesn't change published" do
            expect { @book1.published = true }.to_not change { @book1.published }
          end
        end

        context "when setting to false" do
          it "sets published_at to nil" do
            expect { @book1.published = false }.to change { @book1.published_at }.to(nil)
          end

          it "sets published to false" do
            expect { @book1.published = false }.to change { @book1.published }.from(true).to(false)
          end
        end

      end
    end

  end


end
