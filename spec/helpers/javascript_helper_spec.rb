require 'spec_helper'

describe Releaf::JavascriptHelper do

  describe "#jquery_date_format" do
    context 'when argument is not a String' do
      it "raises ArgumentError" do
        expect { helper.jquery_date_format 123 }.to raise_error ArgumentError
      end
    end

    context 'when argument is a string' do
      it "returns a String" do
        expect( helper.jquery_date_format("asd") ).to be_a(String)
      end

      it "translates Ruby date format to jQuery date format" do
        expect( helper.jquery_date_format("%H:%M:%S") ).to eq('HH:mm:ss')
      end
    end
  end

end
