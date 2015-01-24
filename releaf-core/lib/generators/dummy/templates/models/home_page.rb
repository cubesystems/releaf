class HomePage < ActiveRecord::Base
  acts_as_node permit_attributes: [
    :intro_text_html,
    {
      banners_attributes: %w(item_position banner retained_banner remove_banner url _destroy id)
    }
  ]
  has_many :banners, dependent: :destroy
  accepts_nested_attributes_for :banners, allow_destroy: true

  def self.releaf_fields_to_display action
    attrs = super
    attrs << {
      banners: [ :banner_uid, :url ],
    }
    attrs
  end
end
