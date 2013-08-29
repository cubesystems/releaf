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
