module Leaf
  module Slug
    def self.included(base)
      base.class_eval {

        def self.find_object id_or_slug, scope=nil
          raise ArgumentError unless id_or_slug.is_a?(String) or id_or_slug.is_a?(Fixnum)

          unless self.column_names.include?('slug')
            if scope.blank?
              return self.find(id_or_slug)
            else
              return self.send(scope).find(id_or_slug)
            end
          end

          obj = nil

          # if it looks like id, search by id
          if id_or_slug.to_s =~ /\A\d+\z/
            if scope.blank?
              obj = self.find_by_id(id_or_slug)
            else
              obj = self.send(scope).find_by_id(id_or_slug)
            end
          end

          unless obj
            unless self.column_names.include?('ancestry')
              if scope.blank?
                obj = self.find_by_slug(id_or_slug)
              else
                obj = self.send(scope).find_by_slug(id_or_slug)
              end
            else
              slugs = id_or_slug.split('/')
              if scope.blank?
                obj = self.find_by_slug( slugs.shift )
              else
                obj = self.send(scope).find_by_slug( slugs.shift )
              end
              raise ActiveRecord::RecordNotFound unless obj
              slugs.each do |slug_part|
                if scope.blank?
                  obj = obj.children.find_by_slug(slug_part)
                else
                  obj = obj.children.send(scope).find_by_slug(slug_part)
                end
                raise ActiveRecord::RecordNotFound unless obj
              end
            end
          end

          raise ActiveRecord::RecordNotFound unless obj
          return obj
        end

        def to_param
          return id unless self.class.column_names.include?('slug')
          return id if self.slug.blank?
          col_names = self.class.column_names

          if col_names.include?('ancestry')
            return path.pluck(:slug).join('/')
          elsif col_names.include?('lft') && col_names.include?('rgt') && col_names.include?('parent_id') && self.class.respond_to?(:in_list?)
            unless parent_id.blank?
              return parent.to_param + '/' + slug
            else
              return slug
            end
          else
            return slug
          end
        end
      }

    end
  end
end
