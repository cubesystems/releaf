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
          content_class.releaf_fields_to_display(action)
        else
          nil
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
          parent.url + "/" + slug.to_s
        else
          "/" + slug.to_s
        end
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
        %w[content_id depth id item_position lft rgt slug created_at updated_at]
      end

      def attributes_to_copy
        self.class.column_names - attributes_to_not_copy
      end


      def copy parent_id
        prevent_infinite_copy_loop(parent_id)
        begin
          new_node = nil
          self.class.transaction do
            new_node = _copy!(parent_id)
          end
          new_node
        rescue ActiveRecord::RecordInvalid
          add_error_and_raise 'descendant invalid'
        else
          update_settings_timestamp
        end
      end

      def move parent_id
        return if parent_id.to_i == self.parent_id

        self.class.transaction do
          save_under(parent_id)
          descendants.each do |node|
            next if node.valid?
            add_error_and_raise 'descendant invalid'
          end
        end

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

      def add_error_and_raise error
        errors.add(:base, error)
        raise ActiveRecord::RecordInvalid.new(self)
      end

      def duplicate_content
        return nil if content_id.blank?

        new_content = content.dup
        new_content.save!
        new_content
      end

      def copy_attributes_from node
        node.attributes_to_copy.each do |attribute|
          send("#{attribute}=", node.send(attribute))
        end
      end

      def duplicate_under! parent_id
        new_node = nil
        self.class.transaction do
          new_node = self.class.new
          new_node.copy_attributes_from self
          new_node.content_id = duplicate_content.try(:id)
          new_node.prevent_auto_update_settings_timestamp do
            new_node.save_under(parent_id)
          end
        end
        new_node
      end

      def reasign_slug
        self.slug = nil
        ensure_unique_url
      end

      def save_under target_parent_node_id
        self.parent_id = target_parent_node_id
        if validate_root_locale_uniqueness?
          # When copying root nodes it is important to reset locale to nil.
          # Later user should fill in locale. This is needed to prevent
          # Rails errors about conflicting routes.
          self.locale = nil
        end

        self.item_position = self.class.children_max_item_position(self.parent) + 1
        maintain_name
        reasign_slug
        save!
      end

      def prevent_auto_update_settings_timestamp &block
        original = @prevent_auto_update_settings_timestamp
        @prevent_auto_update_settings_timestamp = true
        yield
      ensure
        @prevent_auto_update_settings_timestamp = original
      end

      protected

      def validate_root_locale_uniqueness?
        locale_selection_enabled? && root?
      end

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

      private

      def _copy! parent_id
        new_node = duplicate_under! parent_id

        children.each do |child|
          child.send(:_copy!, new_node.id)
        end
        new_node
      end

      def prevent_infinite_copy_loop(parent_id)
        return if self_and_descendants.find_by_id(parent_id).blank?
        add_error_and_raise("source or descendant node can't be parent of new node")
      end

      def prevent_auto_update_settings_timestamp?
        @prevent_auto_update_settings_timestamp == true
      end

      def update_settings_timestamp
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

      base.after_save :update_settings_timestamp, unless: :prevent_auto_update_settings_timestamp?

      base.acts_as_url :name, url_attribute: :slug, scope: :parent_id, :only_when_blank => true

      base.extend ClassMethods
    end

    include InstanceMethods

  end
end
