%w(core i18n permissions content).each do |gem_name|
  require "releaf-#{gem_name}"
end
