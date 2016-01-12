class Releaf::Builders::PaginationBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  attr_accessor :collection
  attr_accessor :params

  delegate :total_pages, :current_page, :total_entries, :per_page, to: :collection

  def initialize( template, options = {} )
    self.collection = options[:collection]
    self.params     = options[:params]
    super template
  end

  def output
    return nil unless collection.total_pages > 1
    pagination_block
  end

  def pagination_block
    content_tag( :div, class: :pagination ) do
      safe_join { pagination_parts }
    end
  end

  def pagination_parts
    [
      previous_page_button,
      pagination_select,
      next_page_button
    ]
  end

  def previous_page_button
    page_button( -1, 'previous', 'chevron-left' )
  end

  def next_page_button
    page_button( 1, 'next', 'chevron-right' )
  end

  def page_button( offset, class_name, icon_name )
    attributes =
    {
      class: ['secondary', class_name ],
      title: t( "#{class_name.capitalize} page", scope: 'pagination')
    }

    page_number = relative_page_number( offset )

    if page_number.present?
      attributes[:rel]  = relative_page_relationship(offset)
      attributes[:href] = page_url(page_number)
    else
      attributes[:disabled] = true
    end

    button( nil, icon_name, attributes )
  end

  def page_numbers
    (1..total_pages).to_a
  end

  def relative_page_number( offset )
    page_number = current_page + offset
    page_numbers.include?(page_number) ? page_number : nil
  end

  def relative_page_relationship(offset)
    if offset == -1
      :prev
    elsif offset == 1
      :next
    else
      nil
    end
  end

  def page_url(page_number)
    template.url_for( params.merge( page: page_number ))
  end

  def pagination_select
    content_tag('select', name: :page) do
      safe_join do
        pagination_options
      end
    end
  end

  def pagination_options
    page_numbers.map do |page_number|
      attributes = { value: page_number }
      attributes[:selected] = true if page_number == current_page
      content_tag(:option, attributes) { page_label(page_number) }
    end
  end

  def page_label page_number
    first_item_in_page = (page_number - 1) * per_page + 1
    last_item_in_page  = [page_number * per_page, total_entries].min
    "#{first_item_in_page}-#{last_item_in_page}"
  end

end
