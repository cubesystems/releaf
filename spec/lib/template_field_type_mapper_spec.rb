require "spec_helper"

describe Releaf::TemplateFieldTypeMapper do

  describe ".field_type_name" do
    it "needs tests"
  end

  describe ".use_i18n?" do
    it "needs tests"
  end


  describe ".field_type_name_for_string" do

    %w[thumbnail_uid image_uid photo_uid photography_uid picture_uid avatar_uid logo_uid banner_uid icon_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'image'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'image'
        end
      end

      context "when attribute name is 'some_#{field_name}'" do
        it "returns 'image'" do
          expect( subject.send(:field_type_name_for_string, "some_#{field_name}", nil) ).to eq 'image'
        end
      end
    end

    %w[image_uid2 uid].each do |field_name|
      context "when attribute_name is '#{field_name}'" do
        it "doesn't return 'image'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to_not eq 'image'
        end

        it "doesn't return 'file'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to_not eq 'file'
        end
      end
    end

    %w[some_uid other_uid cook_file_uid file_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'file'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'file'
        end
      end
    end

    %w[pin password password_confirmation encrypted_password some_password some_password_for_secretary].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'password'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'password'
        end
      end
    end

    %w[this_pin pin_that some_pin_for_admin].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'password'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to_not eq 'password'
        end
      end
    end

    %w[email admin_email].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'email'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'email'
        end
      end
    end

    context "when attribute name is 'email_for_admin'" do
      it "doesn't return 'email'" do
        expect( subject.send(:field_type_name_for_string, 'email_for_admin', nil) ).to_not eq 'email'
      end
    end


    %w[link awesome_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'link'
        end
      end
    end

    context "when attribute name is 'link_to_awesome_site'" do
      it "doesn't return 'link'" do
        expect( subject.send(:field_type_name_for_string, 'link_to_awesome_site', nil) ).to_not eq 'link'
      end
    end

    %w[www homepage admin_homepage www_page homepage_www url homepage_url site_url url_for_this_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'link'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to_not eq 'link'
        end
      end
    end

    %w[www homepage url some_pin uid everything_else html].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'text'" do
          expect( subject.send(:field_type_name_for_string, field_name, nil) ).to eq 'text'
        end
      end
    end
  end # describe ".field_type_name_for_string"


  describe '.field_type_name_for_text' do
    %w[url homepage random_url random_homepage].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'url'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to eq 'url'
        end
      end
    end

    %w[url_for_site home_page homepage_for_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'url'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to_not eq 'url'
        end
      end
    end

    %w[random_link cool_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link_or_url'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to eq 'link_or_url'
        end
      end
    end

    %w[link_to_site link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'link_or_url'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to_not eq 'link_or_url'
        end
      end
    end

    %w[html random_html].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'richtext'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to eq 'richtext'
        end
      end
    end

    context "when attribute name is 'html_for_description'" do
      it "doesn't return 'richtext'" do
        expect( subject.send(:field_type_name_for_text, 'html_for_description', nil) ).to_not eq 'richtext'
      end
    end

    %w[text description random html_text].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'textarea'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to eq 'textarea'
        end
      end
    end

  end # describe '.field_type_name_for_text'

  describe ".field_type_name_for_datetime" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'datetime'" do
          expect( subject.send(:field_type_name_for_datetime, field_name, nil) ).to eq 'datetime'
        end
      end
    end
  end # describe ".field_type_name_for_datetime" do

  describe ".field_type_name_for_date" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'date'" do
          expect( subject.send(:field_type_name_for_date, field_name, nil) ).to eq 'date'
        end
      end
    end
  end # describe ".field_type_name_for_date" do

  describe ".field_type_name_for_time" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'time'" do
          expect( subject.send(:field_type_name_for_time, field_name, nil) ).to eq 'time'
        end
      end
    end
  end # describe ".field_type_name_for_time" do

  describe ".field_type_name_for_boolean" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'boolean'" do
          expect( subject.send(:field_type_name_for_boolean, field_name, nil) ).to eq 'boolean'
        end
      end
    end
  end # describe ".field_type_name_for_boolean" do


  describe ".field_type_name_for_virtual" do

    %w[thumbnail_uid image_uid photo_uid photography_uid picture_uid avatar_uid logo_uid banner_uid icon_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'image'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'image'
        end
      end

      context "when attribute name is 'some_#{field_name}'" do
        it "returns 'image'" do
          expect( subject.send(:field_type_name_for_virtual, "some_#{field_name}", nil) ).to eq 'image'
        end
      end
    end

    %w[image_uid2 uid].each do |field_name|
      context "when attribute_name is '#{field_name}'" do
        it "doesn't return 'image'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to_not eq 'image'
        end

        it "doesn't return 'file'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to_not eq 'file'
        end
      end
    end

    %w[some_uid other_uid cook_file_uid file_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'file'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'file'
        end
      end
    end

    %w[pin password password_confirmation encrypted_password some_password some_password_for_secretary].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'password'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'password'
        end
      end
    end

    %w[this_pin pin_that some_pin_for_admin].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'password'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to_not eq 'password'
        end
      end
    end

    %w[email admin_email].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'email'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'email'
        end
      end
    end

    context "when attribute name is 'email_for_admin'" do
      it "doesn't return 'email'" do
        expect( subject.send(:field_type_name_for_virtual, 'email_for_admin', nil) ).to_not eq 'email'
      end
    end

    %w[link awesome_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link_or_url'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'link_or_url'
        end
      end
    end

    context "when attribute name is 'link_to_awesome_site'" do
      it "doesn't return 'link_or_url'" do
        expect( subject.send(:field_type_name_for_virtual, 'link_to_awesome_site', nil) ).to_not eq 'link_or_link'
      end
    end

    %w[url homepage random_url random_homepage].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'url'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'url'
        end
      end
    end

    %w[url_for_site home_page homepage_for_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'url'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to_not eq 'url'
        end
      end
    end

    %w[random_link cool_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link_or_url'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'link_or_url'
        end
      end
    end

    context "when attribute name is 'link_to_site'" do
      it "doesn't return 'link_or_url'" do
        expect( subject.send(:field_type_name_for_virtual, 'link_to_site', nil) ).to_not eq 'link_or_url'
      end
    end

    %w[html random_html].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'richtext'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'richtext'
        end
      end
    end

    context "when attribute name is 'html_for_description'" do
      it "doesn't return 'richtext'" do
        expect( subject.send(:field_type_name_for_virtual, 'html_for_description', nil) ).to_not eq 'richtext'
      end
    end

    %w[text description html_text].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'textarea'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'textarea'
        end
      end
    end

    %w[creation_date created_on publishing_date published_on date].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'date'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'date'
        end
      end
    end

    context "when attribute name is 'on'" do
      it "doesn't return 'date'" do
        expect( subject.send(:field_type_name_for_virtual, 'on', nil) ).to_not eq 'date'
      end
    end

    %w[random_time time].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'time'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'time'
        end
      end
    end

    %w[created_at published_at something_happened_at].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'datetime'" do
          expect( subject.send(:field_type_name_for_virtual, field_name, nil) ).to eq 'datetime'
        end
      end
    end

    context "when attribute name is 'at'" do
      it "doesn't return 'datetime'" do
        expect( subject.send(:field_type_name_for_virtual, 'time', nil) ).to_not eq 'datetime'
      end
    end

  end # describe ".field_type_name_for_virtual"


  describe ".field_type_name_for_integer" do
    before do
      author = FactoryGirl.create(:author)
      @book = FactoryGirl.create(:book, :author => author)
    end

    context "when attributes ends with '_id'" do
      context "when there's an ActiveRecord association" do
        it "returns 'test'" do
          expect( subject.send(:field_type_name_for_integer, 'author_id', @book) ).to eq 'item'
        end
      end

      context "when there's no ActiveRecord association" do
        it "returns 'text'" do
          expect( subject.send(:field_type_name_for_integer, 'random_field_id', @book) ).to eq 'text'
        end
      end
    end

    context "when attribute doesn't end with '_id'" do
      it "returns 'text'" do
        expect( subject.send(:field_type_name_for_integer, 'random_field', nil) ).to eq 'text'
      end
    end
  end # describe ".field_type_name_for_integer"

end
