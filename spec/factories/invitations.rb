FactoryBot.define do
  factory :invitation do
    inviter { nil }
    email { "MyString" }
    token { "MyString" }
  end
end
