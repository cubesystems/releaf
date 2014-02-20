require 'spec_helper'
describe "Releaf authorization" do
  let(:admin){ FactoryGirl.create(:admin) }

  context "when unauthorized user open restricted url" do
    it "redirects to it after authorization" do
      current_unauthorized_url = new_releaf_translation_group_url(test: "yes")
      visit current_unauthorized_url

      within("form.login") do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
        click_button 'Sign in'
      end

      expect(current_url).to eq current_unauthorized_url
    end
  end

  context "when unauthorized user open login page" do
    it "redirects to role default controller after authorization" do
      visit releaf_root_url
      within("form.login") do
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
        click_button 'Sign in'
      end

      expect(current_url).to eq url_for(action: 'index', controller: '/' + admin.role.default_controller)
    end
  end
end
