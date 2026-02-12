puts "Starting seeds..."
start_time = Time.current

puts "Cleaning up existing data"
QuizQuestion.delete_all
Quiz.delete_all
User.delete_all
Word.delete_all
WordTag.delete_all

puts "Creating words.."
start_time = Time.current

words_data = [
  { japanese: "猫", reading: "ねこ", english: "cat" },
  { japanese: "犬", reading: "いぬ", english: "dog" },
  { japanese: "鳥", reading: "とり", english: "bird" },
  { japanese: "魚", reading: "さかな", english: "fish" },
  { japanese: "本", reading: "ほん", english: "book" },
  { japanese: "車", reading: "くるま", english: "car" },
  { japanese: "家", reading: "いえ", english: "house" },
  { japanese: "学校", reading: "がっこう", english: "school" },
  { japanese: "先生", reading: "せんせい", english: "teacher" },
  { japanese: "学生", reading: "がくせい", english: "student" },
  { japanese: "友達", reading: "ともだち", english: "friend" },
  { japanese: "食べ物", reading: "たべもの", english: "food" },
  { japanese: "飲み物", reading: "のみもの", english: "drink" },
  { japanese: "水", reading: "みず", english: "water" },
  { japanese: "火", reading: "ひ", english: "fire" },
  { japanese: "風", reading: "かぜ", english: "wind" },
  { japanese: "山", reading: "やま", english: "mountain" },
  { japanese: "川", reading: "かわ", english: "river" },
  { japanese: "海", reading: "うみ", english: "sea" },
  { japanese: "空", reading: "そら", english: "sky" },
  { japanese: "雨", reading: "あめ", english: "rain" },
  { japanese: "雪", reading: "ゆき", english: "snow" },
  { japanese: "花", reading: "はな", english: "flower" },
  { japanese: "木", reading: "き", english: "tree" },
  { japanese: "草", reading: "くさ", english: "grass" }

]

system_tags = [
  { name: "N5", color: "#4CAF50" },
  { name: "N4", color: "#8BC34A" },
  { name: "N3", color: "#CDDC39" },
  { name: "N2", color: "#FFC107" },
  { name: "N1", color: "#FF5722" }
]

system_tags.each do |tag|
  WordTag.create(name: tag[:name], user_id: nil, color: tag[:color])
end

words = Word.create!(words_data)
password_digest = BCrypt::Password.create("password123")

elapsed = (Time.current - start_time).round(2)
puts "Created #{words.count} words (#{elapsed}s)"

puts "Creating 10,000 users..."
start_time = Time.current
users_data = []
10_000.times do |i|
  users_data << {
    name: "User#{i + 1}",
    email: "user#{i + 1}@example.com",
    password_digest: password_digest,
    created_at: Time.current,
    updated_at: Time.current
  }
end

User.insert_all(users_data)
elapsed = (Time.current - start_time).round(2)
puts "Created 10,000 users (#{elapsed}s)"

user_ids = User.pluck(:id)

puts "Creating quizzes for users..."
start_time = Time.current
quizzes_data = []
quiz_questions_data = []

user_ids.each_with_index do |user_id, index|
  quiz_count = rand(1..10)

  quiz_count.times do |q|
    score = rand(0..10)

    quiz = {
      user_id: user_id,
      status: "completed",
      total_questions: 10,
      current_questions_number: 10,
      score: score,
      started_at: rand(30.days.ago..Time.current),
      completed_at: rand(29.days.ago..Time.current),
      created_at: Time.current,
      updated_at: Time.current
    }

    quizzes_data << quiz
  end

  if (index + 1) % 1000 == 0
    puts "  Processed #{index + 1} users..."
  end
end

Quiz.insert_all(quizzes_data)
elapsed = (Time.current - start_time).round(2)
puts "Created #{quizzes_data.count} quizzes (#{elapsed}s)"




puts "Creating quiz questions..."
start_time = Time.current
quiz_ids = Quiz.pluck(:id)
word_ids = words.pluck(:id)
quiz_questions_data = []

words_hash = words.index_by(&:id)

wrong_answers_pool = {}
word_ids.each do |word_id|
  wrong_answers_pool[word_id] = word_ids - [ word_id ]
end

quiz_ids.each_with_index do |quiz_id, index|
  selected_words = word_ids.sample(10)

  selected_words.each do |word_id|
    word = words_hash[word_id]

    correct_answer = word.english

    wrong_word_ids = wrong_answers_pool[word_id].sample(2)
    wrong_answers = wrong_word_ids.map { |id| words_hash[id].english }
    choices = ([ correct_answer ] + wrong_answers).shuffle

    user_answer = rand < 0.7 ? correct_answer : choices.sample
    is_correct = user_answer == correct_answer

    quiz_questions_data << {
      quiz_id: quiz_id,
      word_id: word_id,
      user_answer: user_answer,
      is_correct: is_correct,
      choices: choices.to_json,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  if (index + 1) % 1000 == 0
    puts "  Processed #{index + 1} quizzes..."
  end
end

QuizQuestion.insert_all(quiz_questions_data)
elapsed = (Time.current - start_time).round(2)
puts "Created #{quiz_questions_data.count} quiz questions (#{elapsed}s)"

puts "Seed completed!"
total_elapsed = (Time.current - start_time).round(2)
puts "Users: #{User.count}"
puts "Quizzes: #{Quiz.count}"
puts "Quiz Questions: #{QuizQuestion.count}"
puts "Total time: #{total_elapsed}s"

User.create(name: "Admin User", email: "admin@example.com", password: "password")
puts "Created admin user with email"
