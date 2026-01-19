FactoryBot.define do
  factory :user_word do
    user { nil }
    word { nil }
    memorized { false }
    quiz_count { 1 }
    correct_count { 1 }
    last_studied_at { "2026-01-19 19:43:08" }
  end
end
