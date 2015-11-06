require 'rails_helper'
feature "Authorization" do
  let(:user){ create(:user) }

  scenario "Url preserving after authorization" do
    current_unauthorized_url = new_admin_book_url
    visit current_unauthorized_url

    within("form") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_url).to eq current_unauthorized_url
  end

  scenario "Redirection to role default controller after authorization" do
    visit releaf_root_url
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_url).to eq url_for(action: 'index', controller: '/' + user.role.default_controller)
  end

  scenario "Redirection to role :redirect_to GET parameter after authorization when parameter value is relative url" do
    visit new_releaf_permissions_user_session_url(redirect_to: new_admin_book_path)
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_url).to eq new_admin_book_url
  end

  scenario "Redirection to role default controller after authorization when :redirect_to GET parameter is absolute url" do
    visit new_releaf_permissions_user_session_url(redirect_to: new_admin_book_url)
    within("form.login") do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    expect(current_url).to eq url_for(action: 'index', controller: '/' + user.role.default_controller)
  end
end
