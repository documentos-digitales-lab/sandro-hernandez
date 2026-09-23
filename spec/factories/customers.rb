FactoryBot.define do
  sequence(:rfc) { |n| "AAA#{format('%07d', n)}000" }

  factory :customer do
    rfc
  end
end