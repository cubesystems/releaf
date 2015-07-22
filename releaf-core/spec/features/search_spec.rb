require "spec_helper"

describe Releaf::Search do

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

  let(:search_fields) { [:title]}
      # let(:params) { {relation: BlogPost.all, text: '', fields: search_fields} }

  describe "searching" do
    it "escapes search text" do
      mysql_expected_result = /LIKE LOWER\('%SQL\\\'injection%'\)/
      postgresql_expected_result = /LIKE LOWER\('%SQL''injection%'\)/
      expected_results = ENV['RELEAF_DB'] == 'postgresql' ? postgresql_expected_result : mysql_expected_result

      params = {
        text: "SQL'injection",
        relation: BlogPost.all,
        fields: [:title]
      }
      expect( described_class.prepare(params).to_sql ).to match(expected_results)
    end

    it "supports searches by multiple words" do
      DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

      BlogPost.create!(title: "sick dog")
      post = BlogPost.create!(title: "sick and big dog and heavy")

      params = {
        text: "heavy sick dog",
        relation: BlogPost.all,
        fields: [:title]
      }
      expect( described_class.prepare(params).to_a ).to eq([post])

      BlogPost.delete_all # hack
    end

    it "searches with LIKE %text% statement" do
      DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

      BlogPost.create!(title: "internatio nalization")
      post = BlogPost.create!(title: "internationalization")

      params = {
        text: "national",
        relation: BlogPost.all,
        fields: [:title]
      }
      expect( described_class.prepare(params).to_a ).to eq([post])

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

      params = {
        relation: BlogPost.all,
        text: 'sick big dog paul',
        fields: [:title, "description", comments: [:text, comment_author: ["name"]]]
      }
      expect( described_class.prepare(params).to_a ).to eq([post1])

      BlogPost.delete_all # hack
    end

    context "when no collection passed" do
      it "assigns resource class 'all' scope to collections" do
        DatabaseCleaner.clean # hack due to this https://github.com/Casecommons/with_model/pull/18 (nested transactions)

        BlogPost.create!(title: "sick dog")
        expect( described_class.new(relation: BlogPost, text: '', fields: []).relation.to_sql ).to eq BlogPost.all.to_sql

        params = {
          text: '',
          fields: [],
          relation: BlogPost
        }
        expect( described_class.prepare(params).to_sql ).to eq BlogPost.all.to_sql


        BlogPost.delete_all # hack
      end
    end

    context "when collection passed" do
      it "use passed collection" do
        relation = BlogPost.where(title: "x")
        params = {
          relation: relation,
          text: '',
          fields: []
        }
        expect( described_class.prepare(params) ).to eq relation
      end
    end

    context "when no search or searchable fields given" do
      it "returns unmodified collection scope" do
        relation = BlogPost.where(title: "x")

        params = {
          relation: BlogPost.all,
          text: 'text',
          fields: []
        }

        expect( described_class.prepare(params).to_a ).to eq(relation.to_a)
      end
    end
  end

end
