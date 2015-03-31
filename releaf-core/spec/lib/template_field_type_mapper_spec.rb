require "spec_helper"

describe Releaf::TemplateFieldTypeMapper do
  let(:object){ double("generic object") }

  def file_field_error_message field_name, obj
    "object doesn't respond to `%s` method. Did you forgot to add `file_accessor :%s` to `%s` model?" % [field_name, field_name, obj.class.name]
  end

  def image_field_error_message field_name, obj
    "object doesn't respond to `%s` method. Did you forgot to add `image_accessor :%s` to `%s` model?" % [field_name, field_name, obj.class.name]
  end

  describe ".field_type_name", pending: true do
    it "needs tests"
  end

  describe ".use_i18n?" do
    context "when object translates" do
      context "when given attribute translatable" do
        it "returns true" do
          expect(Releaf::TemplateFieldTypeMapper.use_i18n?(Book.new, :description)).to be true
        end
      end

      context "when attribute does not translatable" do
        it "returns false" do
          expect(Releaf::TemplateFieldTypeMapper.use_i18n?(Book.new, :title)).to be false
        end
      end
    end

    context "when object does not translates" do
      it "returns false" do
        expect(Releaf::TemplateFieldTypeMapper.use_i18n?(Releaf::Permissions::User.new, :password)).to be false
      end
    end
  end

  describe ".image_or_error" do
    context "given field_name that doesn't end with _uid" do
      it "raises ArgumentError" do
        allow(object).to receive(:image)
        expect { subject.send(:image_or_error, 'image', object) }.to raise_error ArgumentError
      end
    end

    context 'given field_name is `image_uid`' do
      context 'when object responds to `image` method' do
        it "returns 'image'" do
          allow(object).to receive(:image)
          expect( subject.send(:image_or_error, 'image_uid', object) ).to eq 'image'
        end
      end

      context 'when object does not respond to `image` method' do
        it 'raises RuntimeError' do
          expect { subject.send(:image_or_error, 'image_uid', object) }.to raise_error(RuntimeError, image_field_error_message('image', object))
        end
      end
    end
  end

  describe ".file_or_error" do
    context "given field_name that doesn't end with _uid" do
      it "raises ArgumentError" do
        allow(object).to receive(:file)
        expect { subject.send(:file_or_error, 'file', object) }.to raise_error ArgumentError
      end
    end

    context 'given field_name is `file_uid`' do
      context 'when object responds to `file` method' do
        it "returns 'file'" do
          allow(object).to receive(:file)
          expect( subject.send(:file_or_error, 'file_uid', object) ).to eq 'file'
        end
      end

      context 'when object does not respond to `file` method' do
        it 'raises RuntimeError' do
          expect { subject.send(:file_or_error, 'file_uid', object) }.to raise_error(RuntimeError, file_field_error_message('file', object))
        end
      end
    end
  end

  describe ".field_type_name_for_string" do
    %w[thumbnail_uid image_uid photo_uid photography_uid picture_uid avatar_uid logo_uid banner_uid icon_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        context "when object responds to '#{field_name.sub(/_uid$/, '')}'" do
          it "returns 'image'" do
            allow(object).to receive(field_name.sub(/_uid$/, '').to_sym)
            expect( subject.send(:field_type_name_for_string, field_name, object) ).to eq 'image'
          end
        end

        context "when object doesn't respond to '#{field_name.sub(/_uid$/, '')}'" do
          it "raises RuntimeError" do
            test_field_name = field_name.sub(/_uid$/, '')
            expect { subject.send(:field_type_name_for_string, field_name, object) }.to raise_error(RuntimeError, image_field_error_message(test_field_name, object))
          end
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
        context "when object responds to '#{field_name.sub(/_uid$/, '')}'" do
          it "returns 'file'" do
            allow(object).to receive(field_name.sub(/_uid$/, '').to_sym)
            expect( subject.send(:field_type_name_for_string, field_name, object) ).to eq 'file'
          end
        end

        context "when object doesn't respond to '#{field_name.sub(/_uid$/, '')}'" do
          it "raises RuntimeError" do
            test_field_name = field_name.sub(/_uid$/, '')
            expect { subject.send(:field_type_name_for_string, field_name, object) }.to raise_error(RuntimeError, file_field_error_message(test_field_name, object))
          end
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
    %w[url homepage random_url random_homepage random_link cool_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to eq 'link'
        end
      end
    end

    %w[url_for_site link_to_site link home_page homepage_for_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'link'" do
          expect( subject.send(:field_type_name_for_text, field_name, nil) ).to_not eq 'link'
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
  describe ".field_type_name_for_float" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'float'" do
          expect( subject.send(:field_type_name_for_float, field_name, nil) ).to eq 'float'
        end
      end
    end
  end # describe ".field_type_name_for_float" do

  describe ".field_type_name_for_integer" do
    before do
      author = FactoryGirl.create(:author)
      @book = FactoryGirl.create(:book, :author => author)
    end

    context "when attributes ends with '_id'" do
      context "when there's an ActiveRecord association" do
        it "returns 'item'" do
          expect( subject.send(:field_type_name_for_integer, 'author_id', @book) ).to eq 'item'
        end
      end

      context "when there's no ActiveRecord association" do
        it "returns 'text'" do
          expect( subject.send(:field_type_name_for_integer, 'random_field_id', @book) ).to eq 'integer'
        end
      end
    end

    context "when attribute doesn't end with '_id'" do
      it "returns 'text'" do
        expect( subject.send(:field_type_name_for_integer, 'random_field', nil) ).to eq 'integer'
      end
    end
  end # describe ".field_type_name_for_integer"
end
