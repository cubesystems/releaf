module Releaf
  class Admin < ActiveRecord::Base
    self.table_name = 'releaf_admins'

    # store UI settings with RailsSettings
    include RailsSettings::Extend

    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    # :registerable
    devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
    validates_presence_of :name, :surname, :role_id, :locale

    belongs_to :role

    attr_accessible \
      :name,
      :surname,
      :role_id,
      :email,
      :locale,
      :password,
      :password_confirmation

    # Filter scope for base admin
    # @param [String] params[:search] one or multiple words to search
    scope :filter, lambda {|params|
      sql_statement = []
      sql_query_params = {}

      if !params.empty?
        if !params[:search].blank?
          nameQuery = []
          params[:search].strip.split(" ").each_with_index do|word, i|
            qquery = ["releaf_admins.name LIKE :word#{i}", "releaf_admins.surname LIKE :word#{i}", "releaf_admins.email LIKE :word#{i}"]
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

    # Concatenate name and surname for object displaying
    def display_name
      [self.name, self.surname].join(' ')
    end
    alias :to_text :display_name

    protected

    # Require password if we have new record or instance have empty password
    def password_required?
      self.new_record? || self.encrypted_password.blank?
    end

  end
end
