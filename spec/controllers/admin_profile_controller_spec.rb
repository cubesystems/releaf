require 'spec_helper'

describe Releaf::AdminProfileController do
  login_as_admin :admin

  describe "#settings" do
    context 'when params[:settings] not Hash' do
      it do
        put 'settings'
        should respond_with 422
      end
    end

    context 'when params[:settings] is Hash' do
      it do
        put 'settings', {settings: {dummy: 'maybe'}}
        should respond_with 200
      end

      it "save given data within current admin settings" do
        put 'settings', {settings: {dummy: 'maybe'}}
        expect(Releaf::Admin.last.settings.dummy).to eq('maybe')
      end

      it "cast bolean values from strings to booleans" do
        put 'settings', {settings: {be_true: 'true', be_false: 'false'}}
        expect(Releaf::Admin.last.settings.all).to eq({"be_true" => true, "be_false" => false})
      end
    end
  end
end
