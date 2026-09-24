require "rails_helper"

RSpec.describe UserProfile, type: :service do
  describe "initialization" do
    it "exposes the full name and image url" do
      profile = UserProfile.new(full_name: "Emily Johnson", image_url: "https://dummyjson.com/icon/emilys/128")

      expect(profile.full_name).to eq("Emily Johnson")
      expect(profile.image_url).to eq("https://dummyjson.com/icon/emilys/128")
    end

    it "defaults the image url to nil" do
      expect(UserProfile.new(full_name: "Emily Johnson").image_url).to be_nil
    end

    it "is present and not null" do
      profile = UserProfile.new(full_name: "Emily Johnson")

      expect(profile).to be_present
      expect(profile).not_to be_null
    end

    it "serializes to a hash for the session" do
      profile = UserProfile.new(full_name: "Emily Johnson", image_url: "avatar")

      expect(profile.to_h).to eq(full_name: "Emily Johnson", image_url: "avatar")
    end
  end

  describe ".null" do
    it "is a single shared instance" do
      expect(UserProfile.null).to equal(UserProfile.null)
    end

    it "reports as null and not present" do
      expect(UserProfile.null).to be_null
      expect(UserProfile.null).not_to be_present
    end

    it "has no real data" do
      expect(UserProfile.null.full_name).to be_nil
      expect(UserProfile.null.image_url).to be_nil
    end

    it "serializes to nil so nothing is stored in the session" do
      expect(UserProfile.null.to_h).to be_nil
    end
  end
end