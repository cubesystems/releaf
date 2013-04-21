# encoding: UTF-8
Given /^there is an (admin) (.+)$/ do |factory, email|
  @current_admin = FactoryGirl.create(factory.to_sym, :email => email)
end
