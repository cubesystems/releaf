module Releaf::Content
  module Node
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
        self.class.updated
      end

      def attributes_to_not_copy
        %w[content_id depth id item_position lft locale rgt slug created_at updated_at]
      end

      def attributes_to_copy
        @attributes_to_copy ||= self.class.column_names - attributes_to_not_copy
      end

      def copy_to_node! parent_id
        prevent_infinite_copy_loop(parent_id)

        new_node = nil
        securely_without_updating_timestamp do
          new_node = duplicate_node
          save_under_node(new_node, parent_id)

          begin
            children.each do |child|
              child.copy_to_node!(new_node.id)
            end
          rescue ActiveRecord::RecordInvalid
            new_node.add_error_and_raise 'descendant invalid'
          end
        end

        self.class.updated
        return new_node
      end

      def move_to_node! parent_id
        return if parent_id.to_i == self.parent_id

        securely_without_updating_timestamp do
          save_under_node(self, parent_id)
          descendants.each do |node|
            next if node.valid?
            add_error_and_raise 'descendant invalid'
          end
        end

        self.class.updated
        self
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

      def securely_without_updating_timestamp &block
        self.class.transaction do
          dont_update_settings_timestamp &block
        end
      end

      def dont_update_settings_timestamp &block
        @dont_update_settings_timestamp = true
        yield
      ensure
        @dont_update_settings_timestamp = false
      end

      def add_error_and_raise error
        errors.add(:base, error)
        raise ActiveRecord::RecordInvalid.new(self)
      end

      protected

      def prevent_infinite_copy_loop(parent_id)
        return if self.self_and_descendants.find_by_id(parent_id).blank?
        add_error_and_raise("source or descendant node can't be parent of new node")
      end

      def duplicate_node
        self.class.new do |new_node|
          attributes_to_copy.each do |attribute|
            new_node.send("#{attribute}=", send(attribute))
          end

          if content_id.present?
            new_content = content.dup
            new_content.save!
            new_node.content_id = new_content.id
          end

          unless new_node.validate_root_locale_uniqueness?
            # When copying root nodes it is important to reset locale to nil.
            # Later user should fill in locale. This is needed to prevent
            # Rails errors about conflicting routes.
            new_node.locale = locale
          end
        end
      end

      def save_under_node node, target_parent_node_id
        node.parent_id = target_parent_node_id
        node.item_position = self.class.children_max_item_position(node.parent) + 1
        node.maintain_name
        self.slug = nil
        self.ensure_unique_url
        node.save!
      end

      def validate_root_locale_uniqueness?
        locale_selection_enabled? && root?
      end

      def validate_parent_node_is_not_self
        return if parent_id.nil?
        if parent_id.to_i == id
          self.errors.add(:parent_id, "can't be parent to itself")
        end
      end

      def validate_parent_is_not_descendant
        return if parent_id.nil?
        if self.descendants.find_by_id(parent_id).present?
          self.errors.add(:parent_id, "descendant can't be parent")
        end
      end

      private

      def auto_update_settings_timestamp
        return if @dont_update_settings_timestamp
        self.class.updated
      end
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
          self.roots.maximum(:item_position) || 0
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
      base.validates_presence_of :parent, if: :parent_id?
      base.validate :validate_parent_node_is_not_self
      base.validate :validate_parent_is_not_descendant

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
