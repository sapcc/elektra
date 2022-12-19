require "spec_helper"

describe ObjectStorage::Object do
  before :each do
    @driver = double("driver").as_null_object
  end

  describe "#basename" do
    it "shows the basename of the given path" do
      {
        "abc" => "abc",
        "abc/" => "abc/",
        "abc.def" => "abc.def",
        "abc.def/" => "abc.def/",
        "abc/def" => "def",
        "abc/def/" => "def/",
        "ab/cd/ef" => "ef",
        "ab/cd/ef/" => "ef/",
      }.each do |path, basename|
        expect(ObjectStorage::Object.new(@driver, path: path).basename).to eq(
          basename,
        )
      end
    end
  end

  describe "#dirname" do
    it "shows the dirname of the given path" do
      {
        "abc" => "",
        "abc/" => "",
        "abc.def" => "",
        "abc.def/" => "",
        "abc/def" => "abc",
        "abc/def/" => "abc",
        "ab/cd/ef" => "ab/cd",
        "ab/cd/ef/" => "ab/cd",
      }.each do |path, dirname|
        expect(ObjectStorage::Object.new(@driver, path: path).dirname).to eq(
          dirname,
        )
      end
    end
  end
end
