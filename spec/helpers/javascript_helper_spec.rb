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
        helper.jquery_date_format("asd").should be_an_instance_of String
      end

      it "translates Ruby date format to jQuery date format" do
        helper.jquery_date_format("%H:%M:%S").should == 'HH:mm:ss'
      end
    end
  end

end
