require 'rails_helper'
feature "Authorization", js: true do
  let(:user){ create(:user) }

  scenario "Url preserving after authorization" do
    current_unauthorized_path = new_admin_book_path
    visit current_unauthorized_path

    within("form") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_path).to eq current_unauthorized_path
  end

  scenario "Redirection to role default controller after authorization" do
    visit releaf_root_path
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_path).to eq url_for(action: 'index', controller: '/' + user.role.default_controller, only_path: true)
  end

  scenario "Redirection to role :redirect_to GET parameter after authorization when parameter value is relative url" do
    visit new_releaf_permissions_user_session_path(redirect_to: new_admin_book_path)
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_path).to eq new_admin_book_path
  end

  scenario "Redirection to role default controller after authorization when :redirect_to GET parameter is absolute url" do
    visit new_releaf_permissions_user_session_path(redirect_to: new_admin_book_url)
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_path).to eq url_for(action: 'index', controller: '/' + user.role.default_controller, only_path: true)
  end
end
