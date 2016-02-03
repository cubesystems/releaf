shared_examples "an Releaf::Service includer" do
  it "includes InternalUpdate module" do
    expect(described_class.included_modules).to include Releaf::Service
  end

  it "has instance #call method" do
    expect(subject.respond_to?(:call)).to be true
  end
end
