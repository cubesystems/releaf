# encoding: UTF-8

Given /^I as an admin am logged in$/ do
  step %{I as an admin am logged in as admin@example.com}
end

Given /^I as an admin am logged in as (.+)$/ do |email|
    step %{there is an admin #{email}}
    step %{I go to the admin page}
    step %{I fill in "Email" with "#{email}"}
    step %{I fill in "Password" with "password"}
    step %{I press "Sign in"}
    step %{I should see Logout link}
end
