require 'spec_helper'

# TODO: rewrite test with anonymous controller
describe Releaf::Content::NodesController, type: :controller do
  before do
    sign_in create(:user)
  end

  describe "#create_releaf_richtext_attachment" do
    let(:file) { Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/cs.png', __dir__), "image/png") }

    context "when file is uploaded" do
      it "renders 'create_releaf_richtext_attachment'" do
        post :create_releaf_richtext_attachment, upload: file
        expect( response ).to be_successful
        expect( response ).to render_template('create_releaf_richtext_attachment')
      end

      it "creates attachment" do
        expect do
          post :create_releaf_richtext_attachment, upload: file
        end.to change { Releaf::RichtextAttachment.count }.by(1)
      end
    end

    context "when no file is uploaded" do
      it "responds with success" do
        post :create_releaf_richtext_attachment
        expect( response ).to be_successful
      end

      it "doesn't create attachment" do
        expect do
          post :create_releaf_richtext_attachment
        end.to_not change { Releaf::RichtextAttachment.count }
      end
    end
  end
end
