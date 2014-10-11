require "spec_helper"

describe Releaf::TemplateFieldTypeMapper do
  def file_field_error_message field_name, obj
    "object doesn't respond to `%s` method. Did you forgot to add `file_accessor :%s` to `%s` model?" % [field_name, field_name, obj.class.name]
  end

  def image_field_error_message field_name, obj
    "object doesn't respond to `%s` method. Did you forgot to add `image_accessor :%s` to `%s` model?" % [field_name, field_name, obj.class.name]
  end

  describe ".field_type_name" do
    context "when .field_type_name returns type" do
      it "returns value of .field_type_name" do
        resource = Object.new
        expect( Releaf::TemplateFieldTypeMapper ).to receive(:column_type).with(resource, :field).and_return('awesome_field')
        expect( Releaf::TemplateFieldTypeMapper.field_type_name(resource, :field) ).to eq 'awesome_field'
      end
    end

    context "when .field_type_name returns nil" do
      it "returns value of #fallback" do
        resource = Object.new
        allow( Releaf::TemplateFieldTypeMapper ).to receive(:column_type).with(resource, :field).and_return(nil)
        expect( Releaf::TemplateFieldTypeMapper ).to receive(:fallback).with(resource, :field).and_return('test')

        expect( Releaf::TemplateFieldTypeMapper.field_type_name(resource, :field) ).to eq 'test'
      end
    end
  end

  describe ".column_type" do

    with_model :Author do
      table do |t|
      end
    end

    with_model :Book do
      table do |t|
        t.string :field_1
        t.integer :field_2
        t.date :field_3
        t.datetime :field_4
        t.time :field_5
        t.boolean :field_6
        t.text :field_7
        t.integer :author_id
      end

      model do
        belongs_to :author
        attr_accessor :virtual_field
      end
    end


    context "when attribute is translatable" do
      it "resolves type of translasions table field"
    end

    context "when attribute is not translatable" do
      let(:resource) { Book.new }

      {
        field_1:          'text',
        field_2:          'text',
        field_3:          'date',
        field_4:          'datetime',
        field_5:          'time',
        field_6:          'boolean',
        field_7:          'textarea',
        author_id:        'item',
        virtual_field:    nil,
        virtual_password: nil
      }.each_pair do |field_name, field_type|
        it "returns correct field type" do
          expect( Releaf::TemplateFieldTypeMapper.column_type(resource, field_name) ).to eq field_type
        end
      end
    end
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
        obj = Object.new
        expect { subject.send(:image_or_error, obj, 'image') }.to raise_error ArgumentError
      end
    end

    context 'given field_name is `image_uid`' do
      context 'when object responds to `image` method' do
        it "returns 'image'" do
          obj = Object.new
          allow(obj).to receive(:image)
          expect( subject.send(:image_or_error, obj, 'image_uid') ).to eq 'image'
        end
      end

      context 'when object does not respond to `image` method' do
        it 'raises RuntimeError' do
          obj = Object.new
          expect { subject.send(:image_or_error, obj, 'image_uid') }.to raise_error(RuntimeError, image_field_error_message('image', obj))
        end
      end
    end
  end

  describe ".file_or_error" do
    context "given field_name that doesn't end with _uid" do
      it "raises ArgumentError" do
        obj = Object.new
        expect { subject.send(:file_or_error, obj, 'file') }.to raise_error ArgumentError
      end
    end

    context 'given field_name is `file_uid`' do
      context 'when object responds to `file` method' do
        it "returns 'file'" do
          obj = Object.new
          allow(obj).to receive(:file)
          expect( subject.send(:file_or_error, obj, 'file_uid') ).to eq 'file'
        end
      end

      context 'when object does not respond to `file` method' do
        it 'raises RuntimeError' do
          obj = Object.new
          expect { subject.send(:file_or_error, obj, 'file_uid') }.to raise_error(RuntimeError, file_field_error_message('file', obj))
        end
      end
    end
  end

  describe ".fallback" do
    %w[password password_confirmation pin].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'password'" do
          obj = Object.new
          expect( subject.send(:fallback, obj, field_name) ).to eq 'password'
        end
      end
    end

    %w[foo bar].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'text'" do
          obj = Object.new
          expect( subject.send(:fallback, obj, field_name) ).to eq 'text'
        end
      end
    end
  end

  describe ".field_type_name_for_string" do
    %w[thumbnail_uid image_uid photo_uid photography_uid picture_uid avatar_uid logo_uid banner_uid icon_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        context "when object responds to '#{field_name.sub(/_uid$/, '')}'" do
          it "returns 'image'" do
            obj = Object.new
            allow(obj).to receive(field_name.sub(/_uid$/, '').to_sym)
            expect( subject.send(:field_type_name_for_string, obj, field_name) ).to eq 'image'
          end
        end

        context "when object doesn't respond to '#{field_name.sub(/_uid$/, '')}'" do
          it "raises RuntimeError" do
            test_field_name = field_name.sub(/_uid$/, '')
            obj = Object.new
            expect { subject.send(:field_type_name_for_string, obj, field_name) }.to raise_error(RuntimeError, image_field_error_message(test_field_name, obj))
          end
        end
      end
    end

    %w[image_uid2 uid].each do |field_name|
      context "when attribute_name is '#{field_name}'" do
        it "doesn't return 'image'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to_not eq 'image'
        end

        it "doesn't return 'file'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to_not eq 'file'
        end
      end
    end

    %w[some_uid other_uid cook_file_uid file_uid].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        context "when object responds to '#{field_name.sub(/_uid$/, '')}'" do
          it "returns 'file'" do
            obj = Object.new
            allow(obj).to receive(field_name.sub(/_uid$/, '').to_sym)
            expect( subject.send(:field_type_name_for_string, obj, field_name) ).to eq 'file'
          end
        end

        context "when object doesn't respond to '#{field_name.sub(/_uid$/, '')}'" do
          it "raises RuntimeError" do
            test_field_name = field_name.sub(/_uid$/, '')
            obj = Object.new
            expect { subject.send(:field_type_name_for_string, obj, field_name) }.to raise_error(RuntimeError, file_field_error_message(test_field_name, obj))
          end
        end
      end
    end

    %w[pin password password_confirmation encrypted_password some_password some_password_for_secretary].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'password'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to eq 'password'
        end
      end
    end

    %w[this_pin pin_that some_pin_for_admin].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'password'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to_not eq 'password'
        end
      end
    end

    %w[email admin_email].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'email'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to eq 'email'
        end
      end
    end

    context "when attribute name is 'email_for_admin'" do
      it "doesn't return 'email'" do
        expect( subject.send(:field_type_name_for_string, nil, 'email_for_admin') ).to_not eq 'email'
      end
    end

    %w[link awesome_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to eq 'link'
        end
      end
    end

    context "when attribute name is 'link_to_awesome_site'" do
      it "doesn't return 'link'" do
        expect( subject.send(:field_type_name_for_string, nil, 'link_to_awesome_site') ).to_not eq 'link'
      end
    end

    %w[www homepage admin_homepage www_page homepage_www url homepage_url site_url url_for_this_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'link'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to_not eq 'link'
        end
      end
    end

    %w[www homepage url some_pin uid everything_else html].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'text'" do
          expect( subject.send(:field_type_name_for_string, nil, field_name) ).to eq 'text'
        end
      end
    end
  end # describe ".field_type_name_for_string"


  describe '.field_type_name_for_text' do
    %w[url homepage random_url random_homepage].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'url'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to eq 'url'
        end
      end
    end

    %w[url_for_site home_page homepage_for_site].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'url'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to_not eq 'url'
        end
      end
    end

    %w[random_link cool_link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'link_or_url'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to eq 'link_or_url'
        end
      end
    end

    %w[link_to_site link].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "doesn't return 'link_or_url'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to_not eq 'link_or_url'
        end
      end
    end

    %w[html random_html].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'richtext'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to eq 'richtext'
        end
      end
    end

    context "when attribute name is 'html_for_description'" do
      it "doesn't return 'richtext'" do
        expect( subject.send(:field_type_name_for_text, nil, 'html_for_description') ).to_not eq 'richtext'
      end
    end

    %w[text description random html_text].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'textarea'" do
          expect( subject.send(:field_type_name_for_text, nil, field_name) ).to eq 'textarea'
        end
      end
    end
  end # describe '.field_type_name_for_text'

  describe ".field_type_name_for_datetime" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'datetime'" do
          expect( subject.send(:field_type_name_for_datetime, nil, field_name) ).to eq 'datetime'
        end
      end
    end
  end # describe ".field_type_name_for_datetime" do
  describe ".field_type_name_for_date" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'date'" do
          expect( subject.send(:field_type_name_for_date, nil, field_name) ).to eq 'date'
        end
      end
    end
  end # describe ".field_type_name_for_date" do
  describe ".field_type_name_for_time" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'time'" do
          expect( subject.send(:field_type_name_for_time, nil, field_name) ).to eq 'time'
        end
      end
    end
  end # describe ".field_type_name_for_time" do
  describe ".field_type_name_for_boolean" do
    %w[no matter what].each do |field_name|
      context "when attribute name is '#{field_name}'" do
        it "returns 'boolean'" do
          expect( subject.send(:field_type_name_for_boolean, nil, field_name) ).to eq 'boolean'
        end
      end
    end
  end # describe ".field_type_name_for_boolean" do

  describe ".field_type_name_for_integer" do
    let(:book) { Book.new }

    context "when attributes ends with '_id'" do
      context "when there's an ActiveRecord association" do
        it "returns 'item'" do
          expect( subject.send(:field_type_name_for_integer, book, 'author_id') ).to eq 'item'
        end
      end

      context "when there's no ActiveRecord association" do
        it "returns 'text'" do
          expect( subject.send(:field_type_name_for_integer, book, 'random_field_id') ).to eq 'text'
        end
      end
    end

    context "when attribute doesn't end with '_id'" do
      it "returns 'text'" do
        expect( subject.send(:field_type_name_for_integer, nil, 'random_field') ).to eq 'text'
      end
    end
  end # describe ".field_type_name_for_integer"
end
