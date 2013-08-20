class Book < ActiveRecord::Base
  include Releaf::BooleanAt

  boolean_at :published_at

  attr_accessible :title, :year, :author_id, :year, :author, :genre, :summary_html, :active, :published, :published_at
  validates_presence_of :title
  belongs_to :author


  alias_attribute :to_text, :title

  scope :filter, lambda {|params|
    sql_statement = []
    sql_query_params = {}

    if !params.empty?
      if !params[:search].blank?
        nameQuery = []
        params[:search].strip.split(" ").each_with_index do|word, i|
          qquery = ["books.title LIKE :word#{i}"]
          nameQuery.push "(" + qquery.join(' OR ') + ")"
          sql_query_params["word#{i}".to_sym] = '%' + word + '%'
        end
        sql_statement.push nameQuery.join(' AND ')
      end
    end

    unless sql_statement.blank?
      where(sql_statement.join(' AND '), sql_query_params)
    end
  }
end
