class UserProfileLoader
  def self.call(customer_id:, client: ExternalUserClient)
    new(customer_id: customer_id, client: client).call
  end

  def initialize(customer_id:, client: ExternalUserClient)
    @customer_id = customer_id
    @client = client
  end

  def call
    data = @client.call(id: @customer_id)
    UserProfile.new(full_name: full_name(data), image_url: data["image"])
  rescue ExternalUserClient::Error
    UserProfile.null
  end

  private

  def full_name(data)
    [data["firstName"], data["lastName"]].compact.join(" ")
  end
end