class Releaf::Settings < RailsSettings::CachedSettings

  cattr_accessor :registry
  @@registry = {}.with_indifferent_access

  def to_text
    var
  end

  def self.register(args)
    if args.is_a? Hash
      list = [args]
    else
      list = args
    end

    list.each do|item|
      @@registry[item[:key]] = item
      @@defaults[item[:key]] = item[:default]
      self[item[:key]] = item[:default] if table_exists? && !where(var: item[:key], thing_type: nil).exists?
    end
  end
end
