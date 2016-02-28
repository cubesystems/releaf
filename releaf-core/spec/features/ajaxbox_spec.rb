require 'rails_helper'
feature "Ajaxbox", js: true do
  background do
    auth_as_user
  end

  scenario "Close ajaxbox with footer 'cancel' button without reloading page" do
    user = Releaf::Permissions::User.last
    visit releaf_permissions_users_path
    click_link user.name
    expect(page).to have_header(text: user.releaf_title)

    open_toolbox_dialog "Delete"
    within_dialog{ click_link "No" }
    expect(page).to_not have_css(".dialog")
    expect(current_path).to eq(edit_releaf_permissions_user_path(user))
  end

  scenario "Close ajaxbox with footer 'cancel' button (wrapped within form) without reloading page" do
    node = create(:home_page_node, name: "MyNode")
    node_path = edit_admin_node_path(node)
    visit node_path
    open_toolbox_dialog "Move"
    within_dialog{ click_link "Cancel" }
    expect(page).to_not have_css(".dialog")
    expect(current_path).to eq(node_path)
  end

  scenario "Close ajaxbox with header 'close' button without reloading page" do
    node = create(:home_page_node, name: "MyNode")
    node_path = edit_admin_node_path(node)
    visit node_path
    open_toolbox_dialog "Add child"
    within_dialog{ find("button.close").click }
    expect(page).to_not have_css(".dialog")
    expect(current_path).to eq(node_path)
  end

  scenario "Drag ajaxbox within header" do
    node = create(:home_page_node, name: "MyNode")
    node_path = edit_admin_node_path(node)
    visit node_path
    open_toolbox_dialog "Add child"
    header = find(".dialog > header")
    target = find("body > header a.home")

    start_position = page.driver.evaluate_script <<-EOS
      function() {
        var ele  = jQuery(".dialog")[0];
        var rect = ele.getBoundingClientRect();
        return [rect.left, rect.top];
      }();
    EOS
    header.drag_to(target)

    end_position = page.driver.evaluate_script <<-EOS
      function() {
        var ele  = jQuery(".dialog")[0];
        var rect = ele.getBoundingClientRect();
        return [rect.left, rect.top];
      }();
    EOS

    expect(start_position).to_not eq(end_position)
  end

  scenario "Ajaxbox without modality (background is clickable)" do
    node = create(:home_page_node, name: "MyNode")
    node_path = edit_admin_node_path(node)
    visit node_path
    open_toolbox_dialog "Add child"

    expect(page).to have_css(".mfp-bg")
    page.driver.click(10, 10)
    expect(page).to_not have_css(".mfp-bg")
  end

  scenario "Ajaxbox with modality (background is not clickable)" do
    user = Releaf::Permissions::User.last
    visit releaf_permissions_users_path
    click_link user.name
    expect(page).to have_header(text: user.releaf_title)
    open_toolbox_dialog "Delete"

    expect(page).to have_css(".mfp-bg")
    page.driver.click(10, 10)
    expect(page).to have_css(".mfp-bg")
    expect(find(".mfp-bg")).to be_visible
  end

  scenario "Ajaxbox single image view" do
    image = Rack::Test::UploadedFile.new(File.expand_path('../../spec/fixtures/unicorn.jpg', __dir__), "image/jpg")
    book = create(:book, cover_image: image)
    visit edit_admin_book_path(book)

    find(".field[data-name='cover_image'] .value-preview img").click
    expect(page).to have_css(".mfp-bg")
    page.driver.click(10, 10)
    expect(page).to_not have_css(".mfp-bg")

    find(".field[data-name='cover_image'] .value-preview img").click

    image_url = find(".field[data-name='cover_image'] .value-preview a.ajaxbox")["href"] + "&ajax=1"
    ajaxbox_image_selector = '.ajaxbox-inner img.mfp-img'
    expect(find(ajaxbox_image_selector)['src']).to eq image_url

    find(".ajaxbox-inner button.close").click
    expect(page).to have_no_css(".mfp-bg")
    expect(page).to have_no_css(ajaxbox_image_selector)
  end
end
