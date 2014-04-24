module Releaf
  module ContentNode
    module InstanceMethods
      def build_content(params, assignment_options=nil)
        self.content = content_class.new(params)
      end

      def own_fields_to_display
        []
      end

      def content_fields_to_display action
        if content_class.respond_to? :releaf_fields_to_display
          return content_class.releaf_fields_to_display(action)
        else
          return nil
        end
      end

      def content_class
        return nil if content_type.blank?
        content_type.constantize
      end

      ##
      # Return node public url
      def url
        if parent_id
          url = parent.url + "/" + slug.to_s
        else
          url = "/" + slug.to_s
        end

        url
      end

      def to_s
        name
      end

      def destroy
        begin
          super
        rescue NameError => e
          raise if content_id.nil? && content_type.nil?
          raise unless e.message == "uninitialized constant #{content_type}"
          # Class was deleted from project.
          # Lets try one more time, but this time set content_type to nil, so
          # rails doesn't try to constantize it
          self.content_id = self.content_type = nil
          self.save(:validate => false)
          retry
        end
        update_settings_timestamp
      end

      def copy_to_node parent_id
        return if parent_id.to_i == id
        return if self.class.find_by_id(parent_id).nil? && parent_id.present?

        new_node = self.class.new
        new_node.name = name
        new_node.locale = locale
        new_node.content_type = content_type
        new_node.active = active
        new_node.protected = self.protected

        new_node.item_position = self.self_and_siblings[-1].item_position + 1

        if content_id.present?
          new_content = content.dup
          new_content.save!
          new_node.content_id = new_content.id
        end

        new_node.parent_id = parent_id
        new_node.maintain_name
        # To regenerate slug
        new_node.slug = nil

        new_node.save!

        children.each do |child|
          child.copy_to_node(new_node.id)
        end

        return new_node
      end

      def move_to_node parent_id
        return if parent_id.to_i == id
        return if parent_id.to_i == self.parent_id
        return if self.class.find_by_id(parent_id).nil? && parent_id.present?

        self.parent_id = parent_id
        maintain_name
        # To regenerate slug
        self.slug = nil
        self.ensure_unique_url

        self.save!
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
        # There seams to be bug in Rails 4.0.0, that prevents us from using exists?
        # exists? will return nil or 1 in this query, instead of true/false (as it should)
        self_and_ancestors.where(active: false).any? == false
      end

      private

      def update_settings_timestamp
        Settings['nodes.updated_at'] = Time.now
      end
    end

    module ClassMethods
      def updated_at
        Settings['nodes.updated_at']
      end
    end

    def self.included base
      base.acts_as_nested_set order_column: :item_position
      base.acts_as_list scope: :parent_id, column: :item_position

      base.default_scope { base.order(:item_position) }

      base.validates_presence_of :name, :slug, :content_type
      base.validates_uniqueness_of :slug, scope: :parent_id
      base.validates_length_of :name, :slug, :content_type, maximum: 255

      base.alias_attribute :to_text, :name

      base.belongs_to :content, polymorphic: true, dependent: :destroy
      base.accepts_nested_attributes_for :content

      base.after_save :update_settings_timestamp

      base.acts_as_url :name, url_attribute: :slug, scope: :parent_id, :only_when_blank => true

      base.extend ClassMethods
    end

    include InstanceMethods

  end
end
