module Releaf::Builders::Utilities
  class ResolveAttributeFieldMethodName
    include Releaf::Service
    attribute :object, Object
    attribute :attribute_name, String

    FIELD_TYPE_RESOLVERS = {
      string: [:image, :file, :password, :email, :link, :text],
      text: [:link, :richtext, :textarea],
      integer: [:item],
      datetime: [],
      date: [],
      time: [],
      float: [],
      decimal: [],
      boolean: [],
    }

    def call
      "releaf_#{field_type}_#{"i18n_" if localized_attribute?}field"
    end

    def field_type
      column_field_type_resolvers.find{|resolver_name| send("#{resolver_name}?") == true } || column_type
    end

    def column_type
      @column_type ||= columns_class.columns_hash[attribute_name] ? columns_class.columns_hash[attribute_name].type : :string
    end

    def columns_class
      localized_attribute? ? object.class::Translation : object.class
    end

    def localized_attribute?
      @localized_attribute ||= (object.class.respond_to?(:translates?) && object.class.translates? &&
                                object.class.translated_attribute_names.include?(attribute_name.to_sym))
    end

    def column_field_type_resolvers
      FIELD_TYPE_RESOLVERS[column_type]
    end

    def image?
      attribute_name.match(/(thumbnail|image|photo|picture|avatar|logo|banner|icon)_uid$/).present? && file?
    end

    def file?
      attribute_name.match(/_uid$/).present? && object.respond_to?(attribute_name.sub(/_uid$/, ''))
    end

    def password?
      attribute_name.match(/(password|^pin$)/).present?
    end

    def email?
      attribute_name.match(/(_email$|^email$)/).present?
    end

    def link?
      attribute_name.match(/(_url$|_link$|^url$|^link$)/).present?
    end

    def richtext?
      attribute_name.match(/(_html$|^html$)/).present?
    end

    def textarea?
      column_type == :text
    end

    def text?
      column_type == :string
    end

    def item?
      attribute_name.match(/_id$/).present? && object.class.reflect_on_association(attribute_name[0..-4].to_sym).present?
    end
  end
end
