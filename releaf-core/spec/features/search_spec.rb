require "spec_helper"

describe Releaf::Search do
  with_model :Profile, scope: :all do
    table do |t|
      t.string :real_name
      t.integer :post_author_id
    end

  end

  with_model :PostAuthor, scope: :all do
    table  do |t|
      t.string :name
    end

    model do
      has_many :blog_posts, -> { where(deleted: false).where('1=1') }
      has_many :edited_posts, foreign_key: :post_editor_id, class_name: :BlogPost
      has_many :replies, class_name: :Comment, through: :blog_posts, source: :comments
      has_one :profile
    end
  end

  with_model :BlogPost, scope: :all do
    table do |t|
      t.string :title
      t.text :description
      t.timestamps(null: true)
      t.integer :post_author_id
      t.integer :post_editor_id
      t.boolean :deleted, default: false, nil: false
    end

    model do
      has_many :comments
      belongs_to :post_author, -> { order(:name) }
      belongs_to :post_editor, class_name: :PostAuthor
    end
  end

  with_model :Comment, scope: :all do
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

  with_model :CommentAuthor, scope: :all do
    table do |t|
      t.string :name
      t.timestamps(null: true)
    end

    model do
      has_many :comments
    end
  end

  before(:all) do
    @profile1 = Profile.create!(real_name: 'unknown')
    @profile2 = Profile.create!(real_name: 'classified')

    @post_author1 = PostAuthor.create!(name: 'author1', profile: @profile1)
    @post_author2 = PostAuthor.create!(name: 'author2', profile: @profile2)

    @post1 = BlogPost.create!(title: "sick dog", post_author: @post_author1)
    @post2 = BlogPost.create!(title: "sick bird", post_author: @post_author1, post_editor: @post_author1)
    @post3 = BlogPost.create!(title: "sick horse", post_author: @post_author2, post_editor: @post_author1)
    @post4 = BlogPost.create!(title: "healty")
    @post5 = BlogPost.create!(title: "sick horse that died", post_author: @post_author1, deleted: true)

    @comment_author1 = CommentAuthor.create!(name: "Paul")
    @comment_author2 = CommentAuthor.create!(name: "John")

    @comment1 = Comment.create!(text: "big and heavy", comment_author: @comment_author1, blog_post: @post1)
    @comment2 = Comment.create!(text: "big and wide", comment_author: @comment_author1, blog_post: @post1)
    @comment3 = Comment.create!(text: "big", comment_author: @comment_author2, blog_post: @post2)
    @comment4 = Comment.create!(text: "small", comment_author: @comment_author2, blog_post: @post2)
    @comment5 = Comment.create!(text: "big", comment_author: @comment_author2, blog_post: @post3)
    @comment6 = Comment.create!(text: "small", comment_author: @comment_author2, blog_post: @post4)
  end

  it "escapes search text" do
    mysql_expected_result = /LIKE LOWER\('%SQL\\\'injection%'\)/
    postgresql_expected_result = /LIKE LOWER\('%SQL''injection%'\)/
    expected_results = ENV['RELEAF_DB'] == 'postgresql' ? postgresql_expected_result : mysql_expected_result

    params = {
      text: "SQL'injection",
      relation: BlogPost,
      fields: [:title]
    }
    expect( described_class.prepare(params).to_sql ).to match(expected_results)
  end

  it "supports searches by multiple words" do
    params = {
      text: "died sick",
      relation: BlogPost,
      fields: [:title]
    }
    expect( described_class.prepare(params).to_a ).to eq([@post5])
  end

  it "searches with LIKE %text% statement" do
    params = {
      text: "thor",
      relation: PostAuthor,
      fields: [:name]
    }
    expect( described_class.prepare(params) ).to match_array([@post_author1, @post_author2])

    params[:text] = 'thor2'
    expect( described_class.prepare(params) ).to match_array([@post_author2])
  end

  it "supports searching in base model columns" do
    params = {
      relation: PostAuthor,
      fields: [:name],
      text: 'author1'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author1])
  end

  it "supports searching in nested association columns" do
    params = {
      relation: PostAuthor,
      fields: [{blog_posts: [:title]}],
      text: 'bird'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author1])
  end

  it "supports searching in belongs_to association columns" do
    params = {
      relation: BlogPost,
      fields: [{post_author: [:name]}],
      text: 'author2'
    }
    expect( described_class.prepare(params) ).to match_array([@post3])
  end

  it "supports searching in has_one association columns" do
    params = {
      relation: PostAuthor,
      fields: [{profile: [:real_name]}],
      text: 'classified'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author2])
  end

  it "supports searching in has_many association columns" do
    params = {
      relation: BlogPost,
      fields: [{comments: [:text]}],
      text: 'heavy'
    }
    expect( described_class.prepare(params) ).to match_array([@post1])

  end

  it "returns unique records even for has_many associations" do
    params = {
      relation: PostAuthor,
      fields: [:name, {blog_posts: [:title], edited_posts: [:title]}],
      text: 'author2'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author2])

    params[:fields] = [:name, {blog_posts: [:title], edited_posts: [:title]}]
  end

  it "suports searching same table via different associations" do
    params = {
      relation: BlogPost,
      fields: [post_author: [:name], post_editor: [:name]],
      text: 'author1'
    }
    expect( described_class.prepare(params) ).to match_array([@post1, @post2, @post3, @post5])

    params[:text] = 'author2'
    expect( described_class.prepare(params) ).to match_array([@post3])
  end

  it "doesn't care about order of search associations" do
    params = {
      relation: BlogPost,
      fields: [post_author: [:name], post_editor: [:name]],
      text: 'author2'
    }
    expect( described_class.prepare(params) ).to match_array([@post3])

    params[:fields] = [post_editor: [:name], post_author: [:name]]
    expect( described_class.prepare(params) ).to match_array([@post3])
  end

  it "supports searching in associations with though option" do
    params = {
      relation: PostAuthor,
      fields: [{replies: [:text]}],
      text: 'wide'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author1])
  end

  it "supports searching in deeply nested association columns" do
    params = {
      relation: PostAuthor,
      fields: [edited_posts: [comments: [comment_author: [:name]]]],
      text: 'john'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author1])
  end

  it "supports associations with scopes" do
    params = {
      relation: PostAuthor,
      fields: [{blog_posts: [:title]}],
      text: 'horse'
    }
    expect( described_class.prepare(params) ).to match_array([@post_author2])
  end

  it "can find record, even even when associated records doesn't exist" do
    params = {
      relation: BlogPost,
      fields: [:title, post_editor: [:name], post_author: [:name]],
      text: 'healty'
    }
    expect( described_class.prepare(params) ).to match_array([@post4])
  end

  it "assigns resource class 'all' scope to collections when no collection passed" do
    params = {
      text: 'foo',
      fields: [],
      relation: BlogPost
    }
    expect( described_class.prepare(params) ).to match_array BlogPost.all
  end

  it "use passed collection when collection passed" do
    relation = BlogPost.where(title: "x")
    params = {
      relation: relation,
      text: '',
      fields: []
    }
    expect( described_class.prepare(params) ).to eq relation
  end

  it "returns unmodified collection scope when no search fields given" do
    relation = BlogPost.where(title: "x")

    params = {
      relation: relation,
      text: 'text',
      fields: []
    }
    expect( described_class.prepare(params)).to eq(relation)
  end

  it "returns unmodified collection scope when no text given" do
    relation = BlogPost.where(title: "x")

    params = {
      relation: relation,
      text: '',
      fields: [:name]
    }
    expect( described_class.prepare(params)).to eq(relation)
  end

end
