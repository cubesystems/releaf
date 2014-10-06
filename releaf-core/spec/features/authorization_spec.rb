require 'spec_helper'
describe "Releaf authorization" do
  let(:user){ FactoryGirl.create(:user) }

  context "when unauthorized user open restricted url" do
    it "redirects to it after authorization" do
      current_unauthorized_url = new_admin_book_url
      visit current_unauthorized_url

      within("form.login") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      expect(current_url).to eq current_unauthorized_url
    end
  end

  context "when unauthorized user open login page" do
    it "redirects to role default controller after authorization" do
      visit releaf_root_url
      within("form.login") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      expect(current_url).to eq url_for(action: 'index', controller: '/' + user.role.default_controller)
    end

    context "when redirect_to parameter is passed" do
      context "when value of redirect_to parameter is absolute url" do
        it "ignores redirect_to parameter" do
          visit new_releaf_permissions_user_session_url(redirect_to: new_admin_book_url)
          within("form.login") do
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            click_button 'Sign in'
          end

          expect(current_url).to eq url_for(action: 'index', controller: '/' + user.role.default_controller)
        end
      end

      context "when value of redirect_to parameter is relative path" do
        it "redirects to redirect_to parameters value" do
          visit new_releaf_permissions_user_session_url(redirect_to: new_admin_book_path)
          within("form.login") do
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            click_button 'Sign in'
          end

          expect(current_url).to eq new_admin_book_url
        end
      end
    end
  end

end
