require "rails_helper"

describe Releaf::Search do

  describe "searching in models attributes" do
    with_model :Tester, scope: :all do
      table do |t|
        t.string :name
        t.string :surname
      end
    end

    before(:all) do
      @tester1 = Tester.create!(name: 'Jānis')
      @tester2 = Tester.create!(name: 'Pēteris', surname: 'Grābeklis')
      @tester3 = Tester.create!(name: 'Pēteris', surname: 'Lazdiņš')
      @tester4 = Tester.create!(surname: 'Lazdiņš')
    end

    it "can search in single column" do
      params = {
        relation: Tester,
        fields: [:name],
        text: 'Pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@tester2, @tester3]
    end

    it "can search in multiple columns" do
      params = {
        relation: Tester,
        fields: [:name, :surname],
        text: 'Lazdiņš Pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@tester3]
    end

    it "is case insensitive" do
      params = {
        relation: Tester,
        fields: [:name],
        text: 'jānis'
      }
      expect( described_class.prepare(params) ).to match_array [@tester1]
    end

    it "doesn't suffer from injections" do
      expected_results = if mysql?
                           /LIKE '%SQL\\\'injection%'/
                         elsif postgresql?
                           /ILIKE '%SQL''injection%'/
                         else
                           fail
                         end
      params = {
        relation: Tester,
        fields: [:name],
        text: "SQL'injection"
      }
      expect( described_class.prepare(params).to_sql ).to match(expected_results)
    end
  end

  describe "searching in has_many association attributes" do
    with_model :Programmer, scope: :all do
      model do
        has_many :projects
      end
    end

    with_model :Project, scope: :all do
      table do |t|
        t.string :title
        t.string :description
        t.integer :programmer_id
      end

      model do
        belongs_to :programmer
      end
    end

    before(:all) do
      @programmer1 = Programmer.create!
      @programmer2 = Programmer.create!
      @programmer3 = Programmer.create!

      Project.create(programmer: @programmer1, title: 'Good')
      Project.create(programmer: @programmer1, title: 'Bad', description: 'legacy code')
      Project.create(programmer: @programmer2, title: 'Ugy', description: 'php')
      Project.create(programmer: @programmer3, title: 'Very good')
      Project.create(programmer: @programmer3, title: 'good', description: 'ruby')
    end

    it "finds records" do
      params = {
        relation: Programmer,
        fields: [projects: [:title]],
        text: 'bad'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer1]
    end

    it "returns distinct records" do
      params = {
        relation: Programmer,
        fields: [projects: [:title]],
        text: 'good'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer1, @programmer3]
    end

    it "searches different columns" do
      params = {
        relation: Programmer,
        fields: [projects: [:title, :description]],
        text: 'good ruby'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer3]
    end
  end

  describe "searching in belongs_to association attributes" do
    with_model :Programmer, scope: :all do
      table do |t|
        t.integer :project_manager_id
      end

      model do
        belongs_to :project_manager
      end
    end

    with_model :ProjectManager, scope: :all do
      table do |t|
        t.string :name
        t.string :surname
      end
    end

    before(:all) do
      project_manager1 = ProjectManager.create!(name: 'Jānis')
      project_manager2 = ProjectManager.create!(name: 'Pēteris', surname: 'Ozols')
      project_manager3 = ProjectManager.create!(name: 'Jānis', surname: 'Ozols')

      @programmer1 = Programmer.create!(project_manager: project_manager1)
      @programmer2 = Programmer.create!(project_manager: project_manager2)
      @programmer3 = Programmer.create!(project_manager: project_manager3)
    end

    it "finds records" do
      params = {
        relation: Programmer,
        fields: [project_manager: [:name]],
        text: 'pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer2]
    end

    it "searches different columns" do
      params = {
        relation: Programmer,
        fields: [project_manager: [:name, :surname]],
        text: 'jānis ozols'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer3]
    end
  end

  describe "searching in has_one association attributes" do
    with_model :Programmer, scope: :all do
      model do
        has_one :account
      end
    end

    with_model :Account, scope: :all do
      table do |t|
        t.string :login
        t.string :email
        t.integer :programmer_id
      end

      model do
        belongs_to :programmer
      end
    end

    before(:all) do
      @programmer1 = Programmer.create!
      @programmer2 = Programmer.create!
      @programmer3 = Programmer.create!

      Account.create!(programmer: @programmer1, login: 'god', email: 'god@example.com')
      Account.create!(programmer: @programmer2, login: 'devil', email: 'devil@example.com')
      Account.create!(programmer: @programmer3, login: 'unknown', email: 'who@example.com')
    end

    it "finds records" do
      params = {
        relation: Programmer,
        fields: [account: [:login]],
        text: 'god'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer1]
    end

    it "searches different columns" do
      params = {
        relation: Programmer,
        fields: [account: [:login, :email]],
        text: 'unknown who'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer3]
    end

  end

  describe "searching in has_many through assocation attributes" do
    with_model :Programmer, scope: :all do
      model do
        has_many :commits
        has_many :projects, through: :commits
      end
    end

    with_model :Commit, scope: :all do
      table do |t|
        t.integer :programmer_id
        t.integer :project_id
      end

      model do
        belongs_to :programmer
        belongs_to :project
      end
    end

    with_model :Project, scope: :all do
      table do |t|
        t.string :name
        t.string :description
      end
    end

    before(:all) do
      @programmer1 = Programmer.create!
      @programmer2 = Programmer.create!
      @programmer3 = Programmer.create!

      project1 = Project.create!(name: 'Good')
      project2 = Project.create!(name: 'Bad', description: 'legacy code')
      project3 = Project.create!(name: 'Ugy', description: 'php')
      project4 = Project.create!(name: 'Very good')
      project5 = Project.create!(name: 'good', description: 'ruby')

      Commit.create!(programmer: @programmer1, project: project1)
      Commit.create!(programmer: @programmer1, project: project2)
      Commit.create!(programmer: @programmer2, project: project2)
      Commit.create!(programmer: @programmer2, project: project3)
      Commit.create!(programmer: @programmer1, project: project4)
      Commit.create!(programmer: @programmer3, project: project5)
    end

    it "finds records" do
      params = {
        relation: Programmer,
        fields: [projects: [:name, :description]],
        text: 'good'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer1, @programmer3]
    end
  end

  describe "searching in has_one through assocation attributes" do
    with_model :Supplier, scope: :all do
      model do |t|
        has_one :account
        has_one :account_history, through: :account
      end
    end

    with_model :Account, scope: :all do
      table do |t|
        t.integer :supplier_id
      end

      model do
        belongs_to :supplier
        has_one :account_history
      end
    end

    with_model :AccountHistory, scope: :all do
      table do |t|
        t.integer :account_id
        t.string :old_login
      end

      model do
        belongs_to :account
      end
    end

    before(:all) do
      @supplier1 = Supplier.create!
      @supplier2 = Supplier.create!
      @supplier3 = Supplier.create!

      account1 = Account.create!(supplier: @supplier1)
      account2 = Account.create!(supplier: @supplier2)
      account3 = Account.create!(supplier: @supplier3)

      AccountHistory.create!(account: account1, old_login: 'marusja')
      AccountHistory.create!(account: account2, old_login: 'ķirmis')
      AccountHistory.create!(account: account3, old_login: 'grauzējs')
    end

    it "finds correct records" do
      params = {
        relation: Supplier,
        fields: [account_history: [:old_login]],
        text: 'ķirmis'
      }
      expect( described_class.prepare(params) ).to match_array [@supplier2]
    end

  end

  describe "searching in polymorphic has_many association" do
    with_model :Note, scope: :all do
      table do |t|
        t.integer :owner_id
        t.string :owner_type
        t.string :text
      end

      model do
        belongs_to :owner, polymorphic: true
      end
    end

    with_model :Account, scope: :all do
      model do
        has_many :notes, as: :owner
      end
    end

    with_model :Supplier, scope: :all do
      model do
        has_many :notes, as: :owner
      end
    end

    before(:all) do
      @account1 = Account.create!
      @account2 = Account.create!
      @supplier1 = Supplier.create!
      @supplier2 = Supplier.create!

      Note.create!(owner: @account1, text: 'one')
      Note.create!(owner: @supplier1, text: 'two')
      Note.create!(owner: @account2, text: 'three')
      Note.create!(owner: @supplier2, text: 'four')
    end

    it "finds correct record" do
      params = {
        relation: Account,
        fields: [notes: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array [@account1]
    end

    it "uses owner_type when joining" do
      params = {
        relation: Account,
        fields: [notes: [:text]],
        text: 'two'
      }
      expect( described_class.prepare(params) ).to match_array []
    end
  end

  describe "searching in polymorphic has_one association" do
    with_model :Note, scope: :all do
      table do |t|
        t.integer :owner_id
        t.string :owner_type
        t.string :text
      end

      model do
        belongs_to :owner, polymorphic: true
      end
    end

    with_model :Account, scope: :all do
      model do
        has_one :note, as: :owner
      end
    end

    with_model :Supplier, scope: :all do
      model do
        has_one :note, as: :owner
      end
    end

    before(:all) do
      @account1 = Account.create!
      @account2 = Account.create!
      @supplier1 = Supplier.create!
      @supplier2 = Supplier.create!

      Note.create!(owner: @account1, text: 'one')
      Note.create!(owner: @supplier1, text: 'two')
      Note.create!(owner: @account2, text: 'three')
      Note.create!(owner: @supplier2, text: 'four')
    end

    it "finds correct record" do
      params = {
        relation: Account,
        fields: [note: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array [@account1]
    end

    it "uses owner_type when joining" do
      params = {
        relation: Account,
        fields: [note: [:text]],
        text: 'two'
      }
      expect( described_class.prepare(params) ).to match_array []
    end

  end

  describe "searching in scoped association" do
    with_model :Post, scope: :all do
      model do
        has_many :comments, -> { where(deleted: false) }
        has_many :deleted_comments, -> { where(deleted: true) }, class_name: :Comment
      end
    end

    with_model :Comment, scope: :all do
      table do |t|
        t.integer :post_id
        t.boolean :deleted, default: false
        t.string :text
      end

      model do
        belongs_to :post
      end
    end

    before(:all) do
      @post1 = Post.create!
      @post2 = Post.create!
      @post3 = Post.create!

      Comment.create!(post: @post1, text: 'one')
      Comment.create!(post: @post2, text: 'one', deleted: true)
      Comment.create!(post: @post3, text: 'two')
      Comment.create!(post: @post3, text: 'one', deleted: true)
    end

    it "finds correct records" do
      params = {
        relation: Post,
        fields: [comments: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array [@post1]
    end

    it "finds correct records" do
      params = {
        relation: Post,
        fields: [deleted_comments: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array [@post2, @post3]
    end
  end

  describe "searching in same table through different associations" do

    with_model :Writer, scope: :all do
      table do |t|
        t.string :name
      end
    end

    with_model :Post, scope: :all do
      table do |t|
        t.integer :writer_id
        t.integer :editor_id
      end

      model do
        belongs_to :writer, class_name: :Writer
        belongs_to :editor, class_name: :Writer
      end
    end

    before(:all) do
      writer1 = Writer.create!(name: 'Jānis')
      writer2 = Writer.create!(name: 'Pēteris')
      writer3 = Writer.create!(name: 'Juris')
      writer4 = Writer.create!(name: 'Jurģis')

      @post1 = Post.create!(writer: writer1, editor: writer2)
      @post2 = Post.create!(writer: writer1, editor: writer3)
      @post3 = Post.create!(writer: writer2, editor: writer1)
      @post4 = Post.create!(writer: writer2)
      @post5 = Post.create!(writer: writer3, editor: writer4)
      @post6 = Post.create!(                 editor: writer3)
    end

    it "returns correct records" do
      params = {
        relation: Post,
        fields: [writer: [:name], editor: [:name]],
        text: 'Pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@post1, @post3, @post4]
    end

    it "returns correct records" do
      params = {
        relation: Post,
        fields: [writer: [:name], editor: [:name]],
        text: 'Juris'
      }
      expect( described_class.prepare(params) ).to match_array [@post2, @post5, @post6]
    end
  end

  describe "searching in association table that is already joined" do
    with_model :Writer, scope: :all do
      table do |t|
        t.string :name
      end
    end

    with_model :Post, scope: :all do
      table do |t|
        t.integer :writer_id
      end

      model do
        belongs_to :writer
      end
    end

    before(:all) do
      writer1 = Writer.create!(name: 'Jānis')
      writer2 = Writer.create!(name: 'Pēteris')
      writer3 = Writer.create!(name: 'Juris')
      writer4 = Writer.create!(name: 'Jurģis')

      @post1 = Post.create!(writer: writer1)
      @post2 = Post.create!(writer: writer1)
      @post3 = Post.create!(writer: writer2)
      @post4 = Post.create!(writer: writer2)
      @post5 = Post.create!(writer: writer3)
      @post6 = Post.create!
    end

    it "returns correct records" do
      params = {
        relation: Post.joins(:writer),
        fields: [writer: [:name]],
        text: 'Pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@post3, @post4]
    end
  end

  describe "searching deeply nested attributes" do
    with_model :Programmer, scope: :all do
      table do |t|
        t.integer :manager_id
      end

      model do
        belongs_to :manager, class_name: :ProjectManager
      end
    end

    with_model :ProjectManager, scope: :all do
      table do |t|
        t.string :name
        t.string :surname
      end

      model do
        has_many :programmers, foreign_key: :manager_id
        has_many :projects, foreign_key: :manager_id
      end
    end

    with_model :Project, scope: :all do
      table do |t|
        t.string :name
        t.integer :manager_id
      end

      model do
        belongs_to :manager, class_name: :ProjectManager
      end
    end

    before(:all) do
      manager1 = ProjectManager.create!
      manager2 = ProjectManager.create!
      manager3 = ProjectManager.create!

      @programmer1 = Programmer.create!(manager: manager1)
      @programmer2 = Programmer.create!(manager: manager2)
      @programmer3 = Programmer.create!(manager: manager2)

      Project.create!(name: 'one', manager: manager1)
      Project.create!(name: 'two', manager: manager1)
      Project.create!(name: 'three', manager: manager2)
      Project.create!(name: 'four', manager: manager3)
    end

    it "returns correct records" do
      params = {
        relation: Programmer,
        fields: [manager: [projects: [:name]]],
        text: 'three'
      }
      expect( described_class.prepare(params) ).to match_array [@programmer2, @programmer3]
    end
  end

  describe "searching with joins and includes" do
    with_model :Writer, scope: :all do
      table do |t|
        t.string :name
      end
    end

    with_model :Post, scope: :all do
      table do |t|
        t.integer :writer_id
      end

      model do
        belongs_to :writer
      end
    end

    before(:all) do
      writer1 = Writer.create!(name: 'Jānis')
      writer2 = Writer.create!(name: 'Pēteris')
      writer3 = Writer.create!(name: 'Juris')
      writer4 = Writer.create!(name: 'Jurģis')

      @post1 = Post.create!(writer: writer1)
      @post2 = Post.create!(writer: writer1)
      @post3 = Post.create!(writer: writer2)
      @post4 = Post.create!(writer: writer2)
      @post5 = Post.create!(writer: writer3)
      @post6 = Post.create!
    end

    it "returns correct records" do
      params = {
        relation: Post.includes(:writer).references(:writer),
        fields: [writer: [:name]],
        text: 'Pēteris'
      }
      expect( described_class.prepare(params) ).to match_array [@post3, @post4]
    end
  end

  describe "searching in polymorphic association form STI class" do
    with_model :Note, scope: :all do
      table do |t|
        t.integer :owner_id
        t.string :owner_type
        t.string :text
      end

      model do
        belongs_to :owner, polymorphic: true
      end
    end

    with_model :Account, scope: :all do
      table do |t|
        t.string :type
      end

      model do
        has_many :notes, as: :owner
      end
    end

    before(:all) do
      class SecretAccount < Account; end

      @account1 = Account.create!
      @account2 = SecretAccount.create!
      @account3 = Account.create!
      @account4 = SecretAccount.create!

      Note.create!(owner: @account1, text: 'one')
      Note.create!(owner: @account2, text: 'two')
      Note.create!(owner: @account3, text: 'three')
      Note.create!(owner: @account4, text: 'four')
    end

    after(:all) do
      # clenaup temp constant
      Object.send(:remove_const, :SecretAccount) if Object.constants.include?(:SecretAccount)
    end

    it "finds correct record" do
      params = {
        relation: SecretAccount,
        fields: [notes: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array []
    end

    it "finds correct record" do
      params = {
        relation: SecretAccount,
        fields: [notes: [:text]],
        text: 'two'
      }
      expect( described_class.prepare(params) ).to match_array [@account2]
    end

    it "finds correct record" do
      params = {
        relation: Account,
        fields: [notes: [:text]],
        text: 'two'
      }
      expect( described_class.prepare(params) ).to match_array [@account2]
    end

    it "finds correct record" do
      params = {
        relation: Account,
        fields: [notes: [:text]],
        text: 'one'
      }
      expect( described_class.prepare(params) ).to match_array [@account1]
    end

  end

  describe "searching in localized attributes" do

    with_model :Post, scope: :all do
      model do
        translates :title
        globalize_accessors
      end
    end

    with_model :PostTranslation, scope: :all do
      table do |t|
        t.integer Post.reflect_on_association(:translations).foreign_key
        t.string :locale
        t.string :title
      end
    end

    before(:all) do
      Post::Translation.send(:table_name=, PostTranslation.table_name)

      @post1 = Post.create!(title_lv: 'bar', title_en: 'foo')
      @post2 = Post.create!(title_lv: 'foo', title_en: 'bar')
      @post3 = Post.create!(title_lv: 'foo', title_en: 'foo')
      @post4 = Post.create!(title_lv: 'bar', title_en: 'bar')
    end

    context "when current locale is lv" do
      before(:each) do
        I18n.locale = 'lv'
      end

      after(:each) do
        I18n.locale = 'en'
      end

      it "it searches in current locale only", focus: true do
        params = {
          relation: Post,
          fields: [translations: [:title]],
          text: 'foo'
        }
        expect( described_class.prepare(params) ).to match_array [@post2, @post3]
      end
    end

    context "when current locale is en" do
      it "it searches in current locale only", focus: true do
        params = {
          relation: Post,
          fields: [translations: [:title]],
          text: 'foo'
        }
        expect( described_class.prepare(params) ).to match_array [@post1, @post3]
      end
    end

  end

end
