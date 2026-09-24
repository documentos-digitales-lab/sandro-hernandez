require "webmock/rspec"

DUMMY_USERS_URL = %r{\Ahttps://dummyjson\.com/users/\d+\z}
DUMMY_USER_FIXTURE = File.read(Rails.root.join("spec/fixtures/dummyjson_users_1.json"))

RSpec.configure do |config|
  # Every example starts from a clean registry with a working dummyjson backend,
  # so login flows in request/controller/feature specs never hit the network.
  # Individual specs can override the endpoint by re-stubbing the same URL.
  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, DUMMY_USERS_URL).to_return(
      status: 200,
      body: DUMMY_USER_FIXTURE,
      headers: { "Content-Type" => "application/json" })
  end
end