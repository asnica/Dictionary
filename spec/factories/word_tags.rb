FactoryBot.define do
  factory :word_tag do
    name { "MyString" }
    description { "MyText" }
    color { "MyString" }
    category { "MyString" }
    user { nil }
  end
end
