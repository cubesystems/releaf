require "spec_helper"

describe Releaf::Search do

  with_model :Profile do
    table do |t|
      t.string :real_name
      t.integer :author_id
    end

  end

  with_model :Author do
    table  do |t|
      t.string :name
    end

    model do
      has_many :blog_posts, -> { where(deleted: false) }
      has_many :edited_posts, foreign_key: :editor_id, class_name: :BlogPost
      has_many :replies, class_name: :Comment, through: :blog_posts, source: :comments
      has_one :profile
    end
  end

  with_model :BlogPost do
    table do |t|
      t.string :title
      t.text :description
      t.timestamps(null: true)
      t.integer :author_id
      t.integer :editor_id
      t.boolean :deleted, default: false, nil: false
    end

    model do
      has_many :comments
      belongs_to :author, -> { order(:name) }
      belongs_to :editor, class_name: :Author
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

      profile1 = Profile.create!(real_name: 'unknown')
      profile2 = Profile.create!(real_name: 'classified')

      post_author1 = Author.create!(name: 'author1', profile: profile1)
      post_author2 = Author.create!(name: 'author2', profile: profile2)

      post1 = BlogPost.create!(title: "sick dog", author: post_author1)
      post2 = BlogPost.create!(title: "sick bird", author: post_author1, editor: post_author1)
      post3 = BlogPost.create!(title: "sick horse", author: post_author2, editor: post_author1)
      post4 = BlogPost.create!(title: "healty")

      comment_author1 = CommentAuthor.create!(name: "Paul")
      comment_author2 = CommentAuthor.create!(name: "John")

      comment1 = Comment.create!(text: "big and heavy", comment_author: comment_author1, blog_post: post1)
      comment2 = Comment.create!(text: "big and wide", comment_author: comment_author1, blog_post: post1)
      comment3 = Comment.create!(text: "big", comment_author: comment_author2, blog_post: post2)
      comment4 = Comment.create!(text: "small", comment_author: comment_author2, blog_post: post2)
      comment5 = Comment.create!(text: "big", comment_author: comment_author2, blog_post: post3)
      comment6 = Comment.create!(text: "small", comment_author: comment_author2, blog_post: post4)

      params = {
        relation: BlogPost.all,
        text: 'sick big dog paul',
        fields: [
          :title,
          "description",

          comments: [
            :text,
            comment_author: [:name],
          ],
          editor: [:name],
          author: [:name],
        ]
      }
      expect( described_class.prepare(params).to_a ).to match_array([post1])

      params.merge!(text: 'sick dog author2')
      expect( described_class.prepare(params).to_a ).to eq([])

      params.merge!(text: 'author2')
      expect( described_class.prepare(params).to_a ).to match_array([post3])

      params.merge!(text: 'author1')
      expect( described_class.prepare(params).to_a ).to match_array([post1, post2, post3])

      post5 = BlogPost.create!(title: "sick horse that died", author: post_author1, deleted: true)
      params = {
        relation: Author,
        text: 'Paul',
        fields: [
          :name,
          replies: [
            :text,
            comment_author: [:name]
          ],
          profile: [:real_name],
          blog_posts: [:title]
        ]
      }
      expect( described_class.prepare(params).to_a ).to match_array([post_author1])

      params.merge!(text: 'Big')
      expect( described_class.prepare(params).to_a ).to match_array([post_author1, post_author2])

      params.merge!(text: 'classif')
      expect( described_class.prepare(params).to_a ).to match_array([post_author2])

      params.merge!(text: 'sick horse')
      expect( described_class.prepare(params).to_a ).to match_array([post_author2])

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
