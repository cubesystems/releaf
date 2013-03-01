module Releaf
  module ApplicationHelper
    def current_feature
      case params[:action].to_sym
      when :index
        return :intex
      when :new, :create
        return :create
      when :edit, :update
        return :edit
      when :destroy, :confirm_destroy
        return :destroy
      else
        return params[:action].to_sym
      end
    end

    def item_to_text item
      return item.respond_to?(:to_text) ? item.to_text : item.to_s
    end
  end
end
