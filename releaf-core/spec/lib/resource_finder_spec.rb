require "spec_helper"

describe Releaf::ResourceFinder do
  let(:subject){ described_class.new(BlogPost) }

  with_model :BlogPost do
    table do |t|
      t.string :title
      t.text :description
      t.timestamps(null: true)
    end

    model do
      has_many :comments
    end
  end

  with_model :Comment do
    table do |t|
      t.string :text
      t.belongs_to :blog_post
      t.belongs_to :comment_author
      t.timestamps(null: true)
    end

    model do
      belongs_to :blog_post
      belongs_to :comment_author
    end
  end

  with_model :CommentAuthor do
    table do |t|
      t.string :name
      t.timestamps(null: true)
    end

    model do
      has_many :comments
    end
  end

  describe "#search" do
    it "escapes search text" do
      mysql_expected_result = /LIKE LOWER\('%SQL\\\'injection%'\)/
      postgresql_expected_result = /LIKE LOWER\('%SQL''injection%'\)/
      expected_results = ENV['RELEAF_DB'] == 'postgresql' ? postgresql_expected_result : mysql_expected_result

      expect( subject.search("SQL'injection", [:title]).to_sql ).to match(expected_results)
    end

    it "supports searches by multiple words" do
      DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

      BlogPost.create!(title: "sick dog")
      post = BlogPost.create!(title: "sick and big dog and heavy")
      expect( subject.search('heavy sick dog', [:title]).to_a ).to eq([post])

      BlogPost.delete_all # hack
    end

    it "searches with LIKE %text% statement" do
      DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

      BlogPost.create!(title: "internatio nalization")
      post = BlogPost.create!(title: "internationalization")
      expect( subject.search('national', [:title]).to_a ).to eq([post])

      BlogPost.delete_all # hack
    end

    it "supports search by nested fields" do
      DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

      post1 = BlogPost.create!(title: "sick dog")
      post2 = BlogPost.create!(title: "sick bird")
      post3 = BlogPost.create!(title: "sick horse")
      post4 = BlogPost.create!(title: "healty")

      author1 = CommentAuthor.create!(name: "Paul")
      author2 = CommentAuthor.create!(name: "John")

      comment = Comment.create!(text: "big and heavy", comment_author: author1, blog_post: post1)
      comment = Comment.create!(text: "big and wide", comment_author: author1, blog_post: post1)
      comment = Comment.create!(text: "big", comment_author: author2, blog_post: post2)
      comment = Comment.create!(text: "small", comment_author: author2, blog_post: post2)
      comment = Comment.create!(text: "big", comment_author: author2, blog_post: post3)
      comment = Comment.create!(text: "small", comment_author: author2, blog_post: post4)

      expect( subject.search('sick big dog paul', [:title, "description", comments: [:text, comment_author: ["name"]]]).to_a ).to eq([post1])

      BlogPost.delete_all # hack
    end

    context "when no collection passed" do
      it "assigns resource class 'all' scope to collections" do
        expect{ subject.search('text', []) }.to change{ subject.collection }.
          from(nil).to(BlogPost.all)
      end
    end

    context "when collection passed" do
      it "use passed collection" do
        expect{ subject.search('text', [], BlogPost.where(title: "x")) }.to change{ subject.collection }.
          from(nil).to(BlogPost.where(title: "x"))
      end
    end

    context "when no search or searchable fields given" do
      it "returns unmodified collection scope" do
        expect(subject.search('text', [], BlogPost.where(title: "x"))).to eq(BlogPost.where(title: "x"))
      end
    end
  end

  describe "#normalize_fields" do
    before do
      subject.collection = BlogPost.all
    end

    context "when searchable attributes given as symbol or string" do
      let(:fields){ [:title, "description"] }

      it "returns normalized table fields and unmodified relations" do
        expect(subject.normalize_fields(BlogPost, fields)).to eq(["#{BlogPost.table_name}.title", "#{BlogPost.table_name}.description"])
      end

      it "does not modify collection" do
        expect{ subject.normalize_fields(BlogPost, fields) }.to_not change{ subject.collection }
      end
    end

    context "when nested searchable fields given" do
      let(:fields){ [:title, "description", comments: [:text, comment_author: ["name"]]] }

      it "returns normalized nested table fields" do
        expect( subject.normalize_fields(BlogPost, fields) ).to eq(["#{BlogPost.table_name}.title", "#{BlogPost.table_name}.description",
                                      "#{Comment.table_name}.text", "#{CommentAuthor.table_name}.name"])
      end

      context "when nested fields have has_many relationship" do
        it "adds uniq (DISTINCT) scope to collection" do
          expect{ subject.normalize_fields(BlogPost, fields) }.to change{ subject.collection }.from(BlogPost.all).to(BlogPost.all.uniq)
        end
      end
    end
  end

  describe "#joins" do
    context "when no relation within given fields" do
      it "returns empty hash" do
        fields = [:title, "description"]
        expect(subject.joins(BlogPost, fields)).to eq({})
      end
    end

    context "when no relationship exists within given fields" do
      it "returns hash with supposed joins" do
        fields = [:title, "description", comments: [:text, comment_author: ["name"]]]
        expect(subject.joins(BlogPost, fields)).to eq( {comments: {comment_author: {}}} )
      end
    end
  end

  describe "#normalized_joins" do
    context "when empty hash given" do
      it "returns empty array" do
        expect(subject.normalized_joins({})).to eq([])
      end
    end

    context "when single level hash given" do
      it "returns associations in given hash as array" do
        expect(subject.normalized_joins(comments: {})).to eq([:comments])
      end
    end

    context "when nested hash given" do
      it "returns array with all nested hash associations" do
        expect(subject.normalized_joins(comments: {comment_author: {}})).to eq([{comments: [:comment_author]}])
      end
    end
  end

  describe "#join_references" do
    it "returns flatten, unique array with relatinship extracted from given hash" do
      expect(subject.join_references([{comments: [:comment_author, :comments]}])).to eq([:comments, :comment_author])
    end
  end
end
