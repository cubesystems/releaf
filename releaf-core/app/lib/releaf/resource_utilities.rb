class Releaf::ResourceUtilities
    # Lists relations for @resource with dependent: :restrict_with_exception
    #
    # @return hash of all related objects, who have dependancy :restrict_with_exception
  def self.restricted_relations(resource)
    restricted_associations(resource).inject({}) do|relations, association|
      relations[association.name.to_sym] = {
        objects: resource.send(association.name),
        controller: association_controller(association)
      }
      relations
    end
  end

  def self.restricted_associations(resource)
    resource.class.reflect_on_all_associations.select do |association|
      restricted_association?(resource, association)
    end
  end

  def self.restricted_association?(resource, association)
    association.options[:dependent] == :restrict_with_exception && resource.send(association.name).exists?
  end

  # Attempts to guess associated controllers name
  #
  # @return controller name
  def self.association_controller(association)
    guessed_name = association.name.to_s.pluralize
    guessed_name if Releaf.application.config.controllers.values.map { |v| v.controller_name }.grep(/(\/#{guessed_name}$|^#{guessed_name}$)/).present?
  end

  def self.destroyable?(resource)
    restricted_associations(resource).empty?
  end
end
