module Releaf
  class Admin < ActiveRecord::Base
    self.table_name = 'releaf_admins'

    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    # :registerable
    devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

    validates_presence_of :name, :surname, :role_id, :email
    validates_uniqueness_of :email, :case_sensitive => false
    belongs_to :role

    image_accessor :avatar

    attr_accessible \
      :avater,
      :name,
      :surname,
      :role_id,
      :email,
      :password,
      :password_confirmation

    scope :filter, lambda {|params|
        fields = []
        values = {}

        if !params.empty?
          if !params[:search].blank?
            params[:search].strip.split(" ").each_with_index do|word, i|
              fields << "email LIKE :email#{i}"
              values["email#{i}".to_sym] = '%' + word + '%'
            end
          end
        end

        if !fields.empty?
          where(fields.join(' AND '), values)
        end
    }

    def display_name
      [self.name, self.surname].join(' ')
    end
    alias :to_text :display_name

    def role
      super || Role.default
    end

    protected

    def password_required?
      self.new_record? || self.encrypted_password.blank?
    end

  end
end
