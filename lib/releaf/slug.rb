module Releaf
  module Slug
    def self.included(base)
      base.class_eval {

        def self.scoped_for_find_by_slug obj, scope_name=nil, scope_args=nil
          unless scope_name.blank?
            if scope_args.nil?
              obj.send(scope_name.to_sym)
            else
              obj.send(scope_name.to_sym, *scope_args)
            end
          else
            obj
          end
        end


        def self.find_object! id_or_slug, scope_name=nil, scope_args=nil
          self.find_object(id_or_slug, scope_name, scope_args) || raise(ActiveRecord::RecordNotFound)
        end

        def self.find_object id_or_slug, scope_name=nil, scope_args=nil
          raise ArgumentError, "id_or_slug must be String or Fixnum" unless id_or_slug.is_a?(String) or id_or_slug.is_a?(Fixnum)

          unless self.column_names.include?('slug')
            return scoped_for_find_by_slug(self, scope_name, scope_args).find(id_or_slug)
          end

          # if it looks like id, search by id first
          if id_or_slug.to_s =~ /\A\d+\z/
            obj = scoped_for_find_by_slug(self, scope_name, scope_args).find_by_id(id_or_slug)
            return obj if obj
          end

          unless self.column_names.include?('ancestry') || self.new.respond_to?(:children)
            return scoped_for_find_by_slug(self, scope_name, scope_args).find_by_slug(id_or_slug)
          else
            slugs = id_or_slug.split('/')

            obj = scoped_for_find_by_slug(self, scope_name, scope_args).find_by_slug( slugs.shift )
            return nil unless obj
            slugs.each do |slug_part|
              obj = scoped_for_find_by_slug(obj.children, scope_name, scope_args).find_by_slug( slug_part )
              return nil unless obj
            end
            return obj
          end
        end

        def to_param
          return id unless self.class.column_names.include?('slug')
          return id if self.slug.blank?
          col_names = self.class.column_names

          if col_names.include?('ancestry')
            return path.pluck(:slug).join('/')
          elsif self.respond_to?(:parent) && parent
            return parent.to_param + '/' + slug
          else
            return slug
          end
        end
      }

    end
  end
end
