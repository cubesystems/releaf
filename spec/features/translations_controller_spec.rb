require 'spec_helper'
describe Releaf::TranslationsController do
  before do
    auth_as_admin
    @role = Releaf::Role.first
  end

  describe "#import" do
    before do
      @group = I18n::Backend::Releaf::TranslationGroup.create(:scope => "time.formats")
      @translation = I18n::Backend::Releaf::Translation.create(:group_id => @group.id, :key => "#{@group.scope}.default")
    end

    it "import xsls file for selected translation group", :js => true do
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

    it "export xsls file for selected translation group", :js => true do
      visit releaf_translation_groups_path
      find('.main > .table tr[data-id="' + @group.id.to_s  + '"] .toolbox button.trigger').click
      click_link 'Export'

      page.response_headers["Content-Type"].should == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      filename = page.response_headers["Content-Disposition"].split("=")[1].gsub("\"","")

      tmp_file = Dir.tmpdir + '/' + filename
      File.open(tmp_file, "wb") { |f| f.write(page.body) }

      book = Roo::Excelx.new(tmp_file)
      book.default_sheet = book.sheets.first
      expect( book.cell(2, 'A') ).to eq('default')
      expect( book.cell(1, 'B') ).to eq('en')
      expect( book.cell(2, 'B') ).to eq('%Y.%m.%d %H:%M')

      File.delete(tmp_file)
    end
  end
end
