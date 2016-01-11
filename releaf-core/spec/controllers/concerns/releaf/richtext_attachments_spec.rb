require 'rails_helper'

describe Admin::NodesController, type: :controller do
  before do
    sign_in create(:user)
  end

  describe "#create_releaf_richtext_attachment" do
    let(:file) { Rack::Test::UploadedFile.new(File.expand_path('../../../fixtures/cs.png', __dir__), "image/png") }

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

  describe "#releaf_richtext_attachment_upload_url" do
    it "returns upload url" do
      allow(subject).to receive(:url_for).with(action: :create_releaf_richtext_attachment).and_return("a")
      expect(subject.releaf_richtext_attachment_upload_url).to eq("a")
    end

    context "when no route exists for controller" do
      it "returns nil" do
        expect(subject.releaf_richtext_attachment_upload_url).to be nil
      end
    end
  end
end
