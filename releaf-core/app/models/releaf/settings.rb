class Releaf::Settings < RailsSettings::CachedSettings
  def to_text
    var
  end

  def self.register_defaults args
    return unless table_exists? # otherwise will get problems on project initalizers with fresh database

    args.each_pair do|key, value|
      unless where(var: key, thing_type: nil).exists?
        self[key] = value
      end
    end
  end
end
