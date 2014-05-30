%w(core i18n_database permissions content).each do |gem_name|
  require "releaf-#{gem_name}"
end
