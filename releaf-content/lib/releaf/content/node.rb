module Releaf::Content
  module Node
    extend ActiveSupport::Concern

      def locale_selection_enabled?
        false
      end

      def build_content(params = {})
        self.content = content_class.new(params)
      end

      def content_class
        content_type.constantize unless content_type.blank?
      end

      # Return node public path
      def path
        "/" + path_parts.join("/") + (trailing_slash_for_path? ? "/" : "")
      end

      def path_parts
        list = []
        list += parent.path_parts if parent
        list << slug.to_s
        list
      end

      def trailing_slash_for_path?
        Rails.application.routes.default_url_options[:trailing_slash] == true
      end

      def to_s
        name
      end

      def destroy
        begin
          content
        rescue NameError => e
          raise if content_id.nil? && content_type.nil?
          raise unless e.message == "uninitialized constant #{content_type}"
          # Class was deleted from project.
          # Lets try one more time, but this time set content_type to nil, so
          # rails doesn't try to constantize it
          update_columns(content_id: nil, content_type: nil)
        end

        super
        self.class.updated
      end

      def attributes_to_not_copy
        list = %w[content_id depth id item_position lft rgt created_at updated_at]
        list << "locale" if locale_before_type_cast.blank?
        list
      end

      def attributes_to_copy
        self.class.column_names - attributes_to_not_copy
      end

      def copy(parent_id)
        Releaf::Content::Node::Copy.call(node: self, parent_id: parent_id)
      end

      def move(parent_id)
        Releaf::Content::Node::Move.call(node: self, parent_id: parent_id)
      end

      # Maintain unique name within parent_id scope.
      # If name is not unique add numeric postfix.
      def maintain_name
        postfix = nil
        total_count = 0

        while self.class.where(parent_id: parent_id, name: "#{name}#{postfix}").where("id != ?", id.to_i).exists? do
          total_count += 1
          postfix = "(#{total_count})"
        end

        if postfix
          self.name = "#{name}#{postfix}"
        end
      end

      # Maintain unique slug within parent_id scope.
      # If slug is not unique add numeric postfix.
      def maintain_slug
        postfix = nil
        total_count = 0

        while self.class.where(parent_id: parent_id, slug: "#{slug}#{postfix}").where("id != ?", id.to_i).exists? do
          total_count += 1
          postfix = "-#{total_count}"
        end

        if postfix
          self.slug = "#{slug}#{postfix}"
        end
      end

      # Returns closest existing locale starting from object itself
      # @return [String] locale
      def locale
        own = super
        if own
          own
        else
          ancestors.reorder("depth DESC").
            where("locale IS NOT NULL").
            first.try(:locale)
        end
      end

      # Check whether object and all its ancestors are active
      # @return [Boolean] returns true if object is available
      def available?
        self_and_ancestors_array.all?(&:active?)
      end

      def self_and_ancestors_array
        preloaded_self_and_ancestors.nil? ? self_and_ancestors.to_a : preloaded_self_and_ancestors
      end

      def reasign_slug
        self.slug = nil
        ensure_unique_url
      end

      def assign_attributes_from(source_node)
        source_node.attributes_to_copy.each do |attribute|
          send("#{attribute}=", source_node.send(attribute))
        end
      end

      def prevent_auto_update_settings_timestamp
        original = @prevent_auto_update_settings_timestamp
        @prevent_auto_update_settings_timestamp = true
        yield
      ensure
        @prevent_auto_update_settings_timestamp = original
      end

      def update_settings_timestamp
        self.class.updated
      end

      def validate_root_locale_uniqueness?
        locale_selection_enabled? && root?
      end

      def invalid_slug_format?
        slug.present? && slug.to_url != slug
      end

      protected

      def validate_parent_node_is_not_self
        return if parent_id.nil?
        return if parent_id.to_i != id
        self.errors.add(:parent_id, "can't be parent to itself")
      end

      def validate_parent_is_not_descendant
        return if parent_id.nil?
        return if self.descendants.find_by_id(parent_id).blank?
        self.errors.add(:parent_id, "descendant can't be parent")
      end

      def validate_slug
        errors.add(:slug, :invalid) if invalid_slug_format?
      end

      private

      def prevent_auto_update_settings_timestamp?
        @prevent_auto_update_settings_timestamp == true
      end

    module ClassMethods
      def updated_at
        Releaf::Settings['releaf.content.nodes.updated_at']
      end

      def updated
        Releaf::Settings['releaf.content.nodes.updated_at'] = Time.now
      end

      def children_max_item_position node
        if node.nil?
          roots.maximum(:item_position) || 0
        else
          node.children.maximum(:item_position) || 0
        end
      end

      def valid_node_content_class_names parent_id=nil
        class_names = []
        ActsAsNode.classes.each do |class_name|
          test_node = self.new(content_type: class_name, parent_id: parent_id)
          test_node.valid?
          class_names.push class_name unless test_node.errors[:content_type].present?
        end
        class_names
      end

      def valid_node_content_classes parent_id=nil
        valid_node_content_class_names(parent_id).map(&:constantize)
      end
    end

    included do
      acts_as_nested_set order_column: :item_position
      acts_as_list scope: :parent_id, column: :item_position, add_new_at: :bottom

      default_scope { order(:item_position) }
      scope :active, ->() { where(active: true) }

      validates_presence_of :name, :slug, :content_type
      validates_uniqueness_of :slug, scope: :parent_id
      validates_length_of :name, :slug, :content_type, maximum: 255
      validates_uniqueness_of :locale, scope: :parent_id, if: :validate_root_locale_uniqueness?
      validates_presence_of :parent, if: :parent_id?
      validate :validate_parent_node_is_not_self
      validate :validate_parent_is_not_descendant
      validate :validate_slug
      belongs_to :content, polymorphic: true, dependent: :destroy
      accepts_nested_attributes_for :content

      after_save :update_settings_timestamp, unless: :prevent_auto_update_settings_timestamp?

      acts_as_url :name, url_attribute: :slug, scope: :parent_id, only_when_blank: true

      attr_accessor :preloaded_self_and_ancestors
    end
  end
end
