require "rails_helper"

RSpec.describe UserProfileLoader, type: :service do
  describe ".call" do
    context "when the client returns a payload" do
      let(:payload) do
        {
          "firstName" => "Emily",
          "lastName" => "Johnson",
          "image" => "https://dummyjson.com/icon/emilys/128"
        }
      end
      let(:client) { double("client", call: payload) }

      it "builds a profile with the full name and avatar" do
        profile = described_class.call(customer_id: 1, client: client)

        expect(profile).to be_present
        expect(profile.full_name).to eq("Emily Johnson")
        expect(profile.image_url).to eq("https://dummyjson.com/icon/emilys/128")
      end

      it "asks the client for the given customer id" do
        expect(client).to receive(:call).with(id: 7)

        described_class.call(customer_id: 7, client: client)
      end

      it "tolerates a missing first or last name" do
        allow(client).to receive(:call).and_return({
          "firstName" => "Emily", "lastName" => nil, "image" => nil
        })

        profile = described_class.call(customer_id: 1, client: client)

        expect(profile.full_name).to eq("Emily")
      end
    end

    context "when the client fails" do
      let(:client) { double("client") }

      before { allow(client).to receive(:call).and_raise(ExternalUserClient::HttpError, "500") }

      it "falls back to the null profile" do
        profile = described_class.call(customer_id: 1, client: client)

        expect(profile).to be_null
        expect(profile.to_h).to be_nil
      end
    end
  end
end