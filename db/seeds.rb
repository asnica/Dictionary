puts "Starting seeds..."
total_start = Time.current

puts "Cleaning up..."
ActiveRecord::Base.connection.execute("TRUNCATE users, word_tags, user_answers, quiz_sessions, user_words, word_taggings, synonyms, words RESTART IDENTITY CASCADE")


puts "Creating words..."
now = Time.current
words_data = [
  { japanese: "猫",     reading: "ねこ",     english: "cat" },
  { japanese: "犬",     reading: "いぬ",     english: "dog" },
  { japanese: "鳥",     reading: "とり",     english: "bird" },
  { japanese: "魚",     reading: "さかな",   english: "fish" },
  { japanese: "本",     reading: "ほん",     english: "book" },
  { japanese: "車",     reading: "くるま",   english: "car" },
  { japanese: "家",     reading: "いえ",     english: "house" },
  { japanese: "学校",   reading: "がっこう", english: "school" },
  { japanese: "先生",   reading: "せんせい", english: "teacher" },
  { japanese: "学生",   reading: "がくせい", english: "student" },
  { japanese: "友達",   reading: "ともだち", english: "friend" },
  { japanese: "食べ物", reading: "たべもの", english: "food" },
  { japanese: "飲み物", reading: "のみもの", english: "drink" },
  { japanese: "水",     reading: "みず",     english: "water" },
  { japanese: "火",     reading: "ひ",       english: "fire" },
  { japanese: "風",     reading: "かぜ",     english: "wind" },
  { japanese: "山",     reading: "やま",     english: "mountain" },
  { japanese: "川",     reading: "かわ",     english: "river" },
  { japanese: "海",     reading: "うみ",     english: "sea" },
  { japanese: "空",     reading: "そら",     english: "sky" },
  { japanese: "雨",     reading: "あめ",     english: "rain" },
  { japanese: "雪",     reading: "ゆき",     english: "snow" },
  { japanese: "花",     reading: "はな",     english: "flower" },
  { japanese: "木",     reading: "き",       english: "tree" },
  { japanese: "草",     reading: "くさ",     english: "grass" }
]
Word.insert_all(words_data.map { |w| w.merge(created_at: now, updated_at: now) })
word_ids   = Word.pluck(:id)
words_hash = Word.all.index_by(&:id)
puts "Created #{Word.count} words"

puts "Creating word tags..."
word_tags_data = [
  { name: "動物", description: "動物に関する単語", color: "#FF5722" },
  { name: "食べ物", description: "食べ物に関する単語", color: "#4CAF50" },
  { name: "自然", description: "自然に関する単語", color: "#2196F3" },
  { name: "学校", description: "学校に関する単語", color: "#9C27B0" },
  { name: "人", description: "人に関する単語", color: "#FFC107" }

]
Wordtag.insert_all(word_tags_data)

puts "Created #{WordTag.count} word tags"

puts "Associating words with tags..."
WordTag.find_each do |tag|
  case tag.name
  when "動物"
    tag.words << Word.where(japanese: [ "猫", "犬", "鳥", "魚" ])
  when "食べ物"
    tag.words << Word.where(japanese: [ "食べ物", "飲み物", "水" ])
  when "自然"
    tag.words << Word.where(japanese: [ "火", "風", "山", "川", "海", "空", "雨", "雪", "花", "木", "草" ])
  when "学校"
    tag.words << Word.where(japanese: [ "学校", "先生", "学生" ])
  when "人"
    tag.words << Word.where(japanese: [ "友達" ])
  end
end





puts "Creating 10,000 users..."
start           = Time.current
password_digest = BCrypt::Password.create("password123")
BATCH           = 1_000
TOTAL           = 10_000

TOTAL.div(BATCH).times do |b|
  User.insert_all(
    BATCH.times.map do |i|
      n = b * BATCH + i + 1
      {
        name:            "User#{n}",
        email:           "user#{n}@example.com",
        password_digest: password_digest,
        confirmed_at:    now,
        created_at:      now,
        updated_at:      now
      }
    end
  )
  puts "  #{(b + 1) * BATCH} / #{TOTAL} users"
end
puts "Created #{User.count} users (#{(Time.current - start).round(2)}s)"

user_ids = User.pluck(:id)


puts "Creating quiz sessions and answers..."
start = Time.current

user_ids.each_slice(BATCH) do |batch_user_ids|
  quiz_sessions_data = []
  user_answers_data  = []

  batch_user_ids.each do |user_id|
    rand(1..5).times do
      sampled_word_ids = word_ids.sample(10)
      score            = rand(0..10)
      worked_at        = rand(30.days.ago..now)

      choice_order = sampled_word_ids.each_with_object({}) do |wid, h|
        correct     = words_hash[wid].reading
        distractors = (word_ids - [ wid ]).sample(2).map { |id| words_hash[id].reading }
        h[wid.to_s] = ([ correct ] + distractors).shuffle
      end

      quiz_sessions_data << {
        user_id:         user_id,
        word_order:      sampled_word_ids,
        current_index:   10,
        status:          "completed",
        score:           score,
        choice_order:    choice_order.to_json,
        recently_worked: worked_at,
        created_at:      worked_at,
        updated_at:      worked_at
      }
    end
  end

  inserted = QuizSession.insert_all(
    quiz_sessions_data,
    returning: [ :id, :word_order, :score ]
  )

  inserted.each do |row|
    session_id    = row["id"]
    word_order    = row["word_order"].tr("[]", "").split(",").map(&:to_i)
    correct_count = row["score"]

    word_order.each_with_index do |wid, i|
      correct_answer = words_hash[wid]&.reading
      next unless correct_answer

      is_correct      = i < correct_count
      selected_answer = is_correct ? correct_answer
                                   : (word_ids - [ wid ]).sample(2)
                                     .map { |id| words_hash[id].reading }
                                     .reject { |r| r == correct_answer }
                                     .first || word_ids.sample.then { |id| words_hash[id].reading }

      user_answers_data << {
        quiz_session_id: session_id,
        word_id:         wid,
        selected_answer: selected_answer,
        is_correct:      is_correct

      }
    end
  end

  UserAnswer.insert_all(user_answers_data)
  puts "  #{batch_user_ids.last}番目のユーザーまで処理完了"
end

User.insert_all([
  {
    name:            "Admin",
    email:           "admin@example.com",
    password_digest: password_digest,
    confirmed_at:    now,
    created_at:      now,
    updated_at:      now
  }
])

puts "\n=== 完了しました！ ==="
puts "単語:        #{Word.count}"
puts "ユーザー:        #{User.count}"
puts "クイズセッション: #{QuizSession.count}"
puts "ユーザー回答:  #{UserAnswer.count}"
puts "時間かかる:        #{(Time.current - total_start).round(2)}s"
