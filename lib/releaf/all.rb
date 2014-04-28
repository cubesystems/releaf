%w(core i18n permissions).each do |gem_name|
  require "releaf-#{gem_name}"
end
