require "rails_helper"

RSpec.describe ExternalUserClient, type: :service do
  let(:body) { File.read(Rails.root.join("spec/fixtures/dummyjson_users_1.json")) }

  describe ".call" do
    it "returns the parsed payload for a successful response" do
      stub_request(:get, DUMMY_USERS_URL).to_return(status: 200, body: body)

      payload = described_class.call(id: 1)

      expect(payload["firstName"]).to eq("Emily")
      expect(payload["lastName"]).to eq("Johnson")
      expect(payload["image"]).to eq("https://dummyjson.com/icon/emilys/128")
    end

    it "requests the given user id" do
      described_class.call(id: 42)

      expect(WebMock).to have_requested(:get, "https://dummyjson.com/users/42")
    end

    context "with error responses" do
      it "raises HttpError on a non-success status" do
        stub_request(:get, DUMMY_USERS_URL).to_return(status: 404, body: "{}")

        expect { described_class.call(id: 1) }.to raise_error(ExternalUserClient::HttpError)
      end

      it "raises TimeoutError on a timeout" do
        stub_request(:get, DUMMY_USERS_URL).to_timeout

        expect { described_class.call(id: 1) }.to raise_error(ExternalUserClient::TimeoutError)
      end

      it "raises ConnectionError on a connection failure" do
        stub_request(:get, DUMMY_USERS_URL)
          .to_raise(SocketError.new("getaddrinfo: Name or service not known"))

        expect { described_class.call(id: 1) }.to raise_error(ExternalUserClient::ConnectionError)
      end

      it "raises ConnectionError on an SSL verification failure" do
        stub_request(:get, DUMMY_USERS_URL)
          .to_raise(OpenSSL::SSL::SSLError.new("certificate verify failed"))

        expect { described_class.call(id: 1) }.to raise_error(ExternalUserClient::ConnectionError)
      end

      it "raises ParseError on invalid JSON" do
        stub_request(:get, DUMMY_USERS_URL).to_return(status: 200, body: "not json")

        expect { described_class.call(id: 1) }.to raise_error(ExternalUserClient::ParseError)
      end
    end
  end
end