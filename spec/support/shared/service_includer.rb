shared_examples "an Releaf::Core::Service includer" do
  it "includes InternalUpdate module" do
    expect(described_class.included_modules).to include Releaf::Core::Service
  end

  it "has instance #call method" do
    expect(subject.respond_to?(:call)).to be true
  end
end
