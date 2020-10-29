module Releaf::ActionController::Search
  extend ActiveSupport::Concern

  included do
    helper_method :searchable_fields
  end

  def searchable_fields
    @searchable_fields ||= Releaf::DefaultSearchableFields.new(resource_class).find
  end

  def search(text)
    return unless feature_available?(:search)
    return if text.blank?
    return if searchable_fields.blank?
    @collection = searcher_class.prepare(relation: @collection, fields: searchable_fields, text: text)
  end

  def searcher_class
    Releaf::Search
  end
end
