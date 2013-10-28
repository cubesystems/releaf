require 'spec_helper'
describe Releaf::TranslationsController do
  before do
    auth_as_admin
    @role = Releaf::Role.first
  end

  describe "#edit", js: true do
    before do
      @group = I18n::Backend::Releaf::TranslationGroup.create(:scope => "admin.global")
      @translation = I18n::Backend::Releaf::Translation.create(:group_id => @group.id, :key => "#{@group.scope}.back_to_list")
    end

    it "saves translations with no content" do
      visit edit_releaf_translation_group_path(@group)
      find(:css, 'tr[id="translation_' + @translation.id.to_s + '"] .translationCell[data-locale="en"] input[type="text"]').set('back to back')
      click_button 'Save'
      expect(page).to have_css('footer a.secondary', text: "back to back")
    end

    it "saves new translations" do
      visit edit_releaf_translation_group_path(@group)
      click_button 'Add item'
      find(:css, 'tr.item.new td.codeColumn input[type="text"]').set('back_to_list2')
      find(:css, 'tr.item.new .translationCell[data-locale="en"] input[type="text"]').set('back to back2')
      click_button 'Save'
      # wait for save complete
      expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Updated")
      # reopen group
      visit edit_releaf_translation_group_path(@group)
      expect(page).to have_css('.body table tr:last-child td.codeColumn input[type="text"][value="back_to_list2"]')
      expect(page).to have_css('.body table tr:last-child td[data-locale="en"] input[type="text"][value="back to back2"]')
    end
  end

  describe "#import" do
    before do
      @group = I18n::Backend::Releaf::TranslationGroup.create(:scope => "time.formats")
      @translation = I18n::Backend::Releaf::Translation.create(:group_id => @group.id, :key => "#{@group.scope}.default")
    end

    it "imports xsls file for selected translation group", :js => true do
      visit edit_releaf_translation_group_path(@group)
      find('.main .toolbox button.trigger').click
      click_button 'Import'
      pending("find out how to upload file within capybara-webkit")
      #Capybara.save_screenshot "shot.png"
      #attach_file "resource_import_file", File.dirname(__FILE__) + '/../fixtures/time.formats.xlsx', :visible => false
    end
  end

  describe "#export" do
    before do
      @group = I18n::Backend::Releaf::TranslationGroup.create(:scope => "time.formats")
      @translation = I18n::Backend::Releaf::Translation.create(:group_id => @group.id, :key => "#{@group.scope}.default")
      (Releaf.available_locales + ["en"]).each do |locale|
        I18n::Backend::Releaf::TranslationData.create(:translation_id => @translation.id, :lang => locale, :localization => "%Y.%m.%d %H:%M")
      end
    end

    it "exports xsls file for selected translation group", :js => true do
      visit releaf_translation_groups_path
      find('.main > .table tr[data-id="' + @group.id.to_s  + '"] .toolbox button.trigger').click
      click_link 'Export'

      expect(page.response_headers["Content-Type"]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

      filename = page.response_headers["Content-Disposition"].split("=")[1].gsub("\"","")

      tmp_file = Dir.tmpdir + '/' + filename
      File.open(tmp_file, "wb") { |f| f.write(page.body) }

      require "roo"
      book = Roo::Excelx.new(tmp_file)
      book.default_sheet = book.sheets.first
      expect( book.cell(2, 'A') ).to eq('default')
      expect( book.cell(1, 'B') ).to eq('en')
      expect( book.cell(2, 'B') ).to eq('%Y.%m.%d %H:%M')

      File.delete(tmp_file)
    end
  end
end
