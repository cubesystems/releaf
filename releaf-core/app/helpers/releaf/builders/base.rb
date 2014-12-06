module Releaf::Builders::Base
  extend ActiveSupport::Concern

  def wrapper(content_or_attributes_with_block, attributes = {}, &block)
    if block_given?
      tag(:div, content_or_attributes_with_block, nil, nil, &block)
    else
      tag(:div, content_or_attributes_with_block, attributes)
    end
  end

  def tag(*args, &block)
    return template.content_tag(*args) unless block_given?

    template.content_tag(*args) do
      block_result = yield
      if block_result.is_a? Array
        safe_join do
          block_result
        end
      else
        block_result.to_s
      end
    end
  end

  def safe_join(&block)
    template.safe_join(yield)
  end

  def params
    template.params
  end

  def t(key, options = {})
    options[:scope] = controller.controller_scope_name unless options.key? :scope
    I18n.t(key, options)
  end


  #
  # Aliases
  #

  delegate :controller, :controller_name, :url_for, :feature_available?, :index_url, :releaf_button, to: :template

  def button(*args)
    releaf_button(*args)
  end

end
