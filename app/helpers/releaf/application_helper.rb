module Releaf
  module ApplicationHelper
    def item_to_text item
      item.respond_to? :to_text ? item.to_text : item.to_s
    end
  end
end
