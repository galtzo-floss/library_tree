RSpec.describe LibraryTree::Version do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end
end
