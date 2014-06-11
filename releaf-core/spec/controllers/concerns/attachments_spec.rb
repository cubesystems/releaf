require 'spec_helper'

# TODO: rewrite test with anonymous controller
describe Releaf::Content::NodesController do
  before do
    sign_in FactoryGirl.create(:user)
  end

  describe "GET #new_attachment" do
    it "renders 'new_attachment' view" do
      get :new_attachment
      expect( response ).to be_successful
      expect( response ).to render_template('new_attachment')
    end
  end

  describe "#create_attachment" do
      let(:image) { Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/cs.png', __dir__), "image/png") }
      let(:file) { Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/time.formats.xlsx', __dir__), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }

    context "when image is uploaded" do
      it "renders '_attachment_image'" do
        post :create_attachment, :file => image
        expect( response ).to be_successful
        expect( response ).to render_template('_attachment_image')
      end

      it "creates attachment" do
        expect do
          post :create_attachment, :file => image
        end.to change { Releaf::Attachment.count }.by(1)
      end
    end

    context "when file is uploaded" do
      it "renders '_attachment_link'" do
        post :create_attachment, :file => file
        expect( response ).to be_successful
        expect( response ).to render_template('_attachment_link')
      end

      it "creates attachment" do
        expect do
          post :create_attachment, :file => file
        end.to change { Releaf::Attachment.count }.by(1)
      end
    end

    context "when no file is uploaded" do
      it "responds with success" do
        post :create_attachment
        expect( response ).to be_successful
      end

      it "doesn't create attachment" do
        expect do
          post :create_attachment
        end.to_not change { Releaf::Attachment.count }
      end
    end
  end
end
