module Releaf
  module ContentNode
    # TODO Node should be configurable

    module InstanceMethods
      def locale_selection_enabled?
        false
      end

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

      def copy_to_node! parent_id
        new_node = self.class.new

        new_node.add_error_and_raise 'cant be parent to itself' if parent_id.to_i == id
        new_node.add_error_and_raise 'parent node doesnt exist' if parent_id.present? && self.class.find_by_id(parent_id).nil?

        self.dont_update_settings_timestamp do
          self.class.transaction do
            new_node.name = name

            new_node.content_type = content_type
            new_node.active = active

            if content_id.present?
              new_content = content.dup
              new_content.save!
              new_node.content_id = new_content.id
            end

            new_node.parent_id = parent_id

            unless new_node.validate_root_locale_uniqueness?
              # When copying root nodes it is important to reset locale to nil.
              # Later user should fill in locale. This is needed to prevent
              # Rails errors about conflicting routes.
              new_node.locale = locale
            end
            new_node.item_position = Node.children_max_item_position(new_node.parent) + 1
            new_node.maintain_name
            # To regenerate slug
            new_node.slug = nil

            new_node.save!

            begin
              children.each do |child|
                child.copy_to_node!(new_node.id)
              end
            rescue ActiveRecord::RecordInvalid
              new_node.add_error_and_raise 'descendant invalid'
            end
          end
        end

        new_node.update_settings_timestamp
        return new_node
      end

      def move_to_node! parent_id
        return if parent_id.to_i == self.parent_id

        if parent_id.present?
          add_error_and_raise 'cant be parent to itself'        if parent_id.to_i == id
          add_error_and_raise 'parent node doesnt exist'        if self.class.find_by_id(parent_id).nil?
          add_error_and_raise 'cant move node under descendant' unless self.descendants.find_by_id(parent_id).nil?
        end

        result = nil
        self.class.transaction do
          dont_update_settings_timestamp do
            self.parent_id = parent_id
            self.item_position = Node.children_max_item_position(self.parent) + 1
            maintain_name
            # To regenerate slug
            self.slug = nil
            self.ensure_unique_url
            self.save!
            descendants.each do |node|
              next if node.valid?
              add_error_and_raise 'descendant invalid'
            end
          end
        end

        update_settings_timestamp
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

      def dont_update_settings_timestamp &block
        @dont_update_settings_timestamp = true
        yield
      ensure
        @dont_update_settings_timestamp = false
      end

      def update_settings_timestamp
        Settings['nodes.updated_at'] = Time.now
      end

      def add_error_and_raise error
        errors.add(:base, error)
        raise ActiveRecord::RecordInvalid.new(self)
      end

      protected

      def validate_root_locale_uniqueness?
        locale_selection_enabled? && root?
      end

      private

      def auto_update_settings_timestamp
        return if @dont_update_settings_timestamp
        update_settings_timestamp
      end

    end

    module ClassMethods
      def updated_at
        Settings['nodes.updated_at']
      end

      def children_max_item_position node
        if node.nil?
          Node.roots.maximum(:item_position) || 0
        else
          node.children.maximum(:item_position) || 0
        end
      end

      def valid_node_content_class_names parent_id=nil
        class_names = []
        ActsAsNode.classes.each do |class_name|
          test_node = Node.new(content_type: class_name, parent_id: parent_id)
          test_node.valid?
          class_names.push class_name unless test_node.errors[:content_type].present?
        end
        return class_names
      end

      def valid_node_content_classes parent_id=nil
        return valid_node_content_class_names(parent_id).map(&:constantize)
      end
    end

    def self.included base
      base.acts_as_nested_set order_column: :item_position
      base.acts_as_list scope: :parent_id, column: :item_position

      base.default_scope { base.order(:item_position) }

      base.validates_presence_of :name, :slug, :content_type
      base.validates_uniqueness_of :slug, scope: :parent_id
      base.validates_length_of :name, :slug, :content_type, maximum: 255
      base.validates_uniqueness_of :locale, scope: :parent_id, if: :validate_root_locale_uniqueness?

      base.alias_attribute :to_text, :name

      base.belongs_to :content, polymorphic: true, dependent: :destroy
      base.accepts_nested_attributes_for :content

      base.after_save :auto_update_settings_timestamp

      base.acts_as_url :name, url_attribute: :slug, scope: :parent_id, :only_when_blank => true

      base.extend ClassMethods
    end

    include InstanceMethods

  end
end
