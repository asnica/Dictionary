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
  { japanese: "草",     reading: "くさ",     english: "grass" },
  { japanese: "食べる", reading: "たべる",   english: "eat" },
  { japanese: "飲む",   reading: "のむ",     english: "drink" },
  { japanese: "行く",   reading: "いく",     english: "go" },
  { japanese: "来る",   reading: "くる",     english: "come" },
  { japanese: "見る",   reading: "みる",     english: "see" },
  { japanese: "聞く",   reading: "きく",     english: "hear" },
  { japanese: "話す",   reading: "はなす",   english: "speak" },
  { japanese: "読む",   reading: "よむ",     english: "read" },
  { japanese: "書く",   reading: "かく",     english: "write" },
  { japanese: "作る",   reading: "つくる",   english: "make" },
  { japanese: "使う",   reading: "つかう",   english: "use" },
  { japanese: "買う",   reading: "かう",     english: "buy" },
  { japanese: "売る",   reading: "うる",     english: "sell" },
  { japanese: "働く",   reading: "はたらく", english: "work" },
  { japanese: "休む",   reading: "やすむ",   english: "rest" },
  { japanese: "勉強",   reading: "べんきょう", english: "study" },
  { japanese: "練習",   reading: "れんしゅう", english: "practice" },
  { japanese: "旅行",   reading: "りょこう", english: "travel" },
  { japanese: "電車",   reading: "でんしゃ", english: "train" },
  { japanese: "駅",     reading: "えき",     english: "station" },
  { japanese: "病院",   reading: "びょういん", english: "hospital" },
  { japanese: "会社",   reading: "かいしゃ", english: "company" },
  { japanese: "会議",   reading: "かいぎ",   english: "meeting" },
  { japanese: "計画",   reading: "けいかく", english: "plan" },
  { japanese: "問題",   reading: "もんだい", english: "problem" },
  { japanese: "解決",   reading: "かいけつ", english: "solve" },
  { japanese: "簡単",   reading: "かんたん", english: "easy" },
  { japanese: "難しい", reading: "むずかしい", english: "difficult" },
  { japanese: "早い",   reading: "はやい",   english: "fast" },
  { japanese: "遅い",   reading: "おそい",   english: "slow" },
  { japanese: "新しい", reading: "あたらしい", english: "new" },
  { japanese: "古い",   reading: "ふるい",   english: "old" },
  { japanese: "高い",   reading: "たかい",   english: "expensive" },
  { japanese: "安い",   reading: "やすい",   english: "cheap" },
  { japanese: "大切",   reading: "たいせつ", english: "important" },
  { japanese: "嬉しい", reading: "うれしい", english: "happy" },
  { japanese: "悲しい", reading: "かなしい", english: "sad" },
  { japanese: "静か",   reading: "しずか",   english: "quiet" },
  { japanese: "賑やか", reading: "にぎやか", english: "lively" },
  { japanese: "美しい", reading: "うつくしい", english: "beautiful" },
  { japanese: "安全",   reading: "あんぜん", english: "safe" },
  { japanese: "危険",   reading: "きけん",   english: "dangerous" }
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
  { name: "人", description: "人に関する単語", color: "#FFC107" },
  { name: "動詞", description: "動作を表す単語", color: "#009688" },
  { name: "形容", description: "性質・状態を表す単語", color: "#795548" },
  { name: "日常", description: "日常生活でよく使う単語", color: "#3F51B5" },
  { name: "仕事", description: "仕事や業務に関する単語", color: "#607D8B" },
  { name: "移動", description: "移動や交通に関する単語", color: "#8BC34A" },
  { name: "感情", description: "感情を表す単語", color: "#E91E63" }

]
WordTag.insert_all(word_tags_data.map { |tag| tag.merge(created_at: now, updated_at: now, category: "system") })

puts "Created #{WordTag.count} word tags"

puts "Associating words with tags..."
system_tag_map = {
  "動物" => [ "猫", "犬", "鳥", "魚" ],
  "食べ物" => [ "食べ物", "飲み物", "水", "食べる", "飲む" ],
  "自然" => [ "火", "風", "山", "川", "海", "空", "雨", "雪", "花", "木", "草" ],
  "学校" => [ "学校", "先生", "学生", "勉強", "練習", "読む", "書く" ],
  "人" => [ "友達", "先生", "学生" ],
  "動詞" => [ "食べる", "飲む", "行く", "来る", "見る", "聞く", "話す", "読む", "書く", "作る", "使う", "買う", "売る", "働く", "休む" ],
  "形容" => [ "簡単", "難しい", "早い", "遅い", "新しい", "古い", "高い", "安い", "大切", "嬉しい", "悲しい", "静か", "賑やか", "美しい", "安全", "危険" ],
  "日常" => [ "本", "家", "車", "友達", "水", "食べ物", "飲み物", "買う", "使う" ],
  "仕事" => [ "会社", "会議", "計画", "問題", "解決", "働く" ],
  "移動" => [ "旅行", "電車", "駅", "行く", "来る" ],
  "感情" => [ "嬉しい", "悲しい", "大切" ]
}

WordTag.system_tags.find_each do |tag|
  japanese_words = system_tag_map[tag.name]
  next unless japanese_words

  tag.words << Word.where(japanese: japanese_words)
end

puts "Creating synonyms..."
synonyms_map = {
  "猫" => [ "ネコ", "にゃんこ" ],
  "犬" => [ "イヌ", "わんこ" ],
  "本" => [ "書籍", "ブック" ],
  "車" => [ "自動車", "クルマ" ],
  "学校" => [ "学園", "スクール" ],
  "先生" => [ "教師", "講師" ],
  "友達" => [ "友人", "仲間" ],
  "食べ物" => [ "食品", "料理" ],
  "飲み物" => [ "飲料", "ドリンク" ],
  "山" => [ "山岳", "岳" ],
  "川" => [ "河川", "リバー" ],
  "海" => [ "オーシャン", "海原" ],
  "空" => [ "天空", "スカイ" ],
  "雨" => [ "降雨", "雨天" ],
  "勉強" => [ "学習", "学び" ],
  "練習" => [ "訓練", "トレーニング" ],
  "旅行" => [ "旅", "トラベル" ],
  "会社" => [ "企業", "職場" ],
  "会議" => [ "ミーティング", "打ち合わせ" ],
  "計画" => [ "プラン", "企画" ],
  "問題" => [ "課題", "トラブル" ],
  "解決" => [ "解消", "克服" ],
  "簡単" => [ "容易", "楽" ],
  "難しい" => [ "困難", "ハード" ],
  "早い" => [ "迅速", "スピーディー" ],
  "遅い" => [ "のろい", "スロー" ],
  "新しい" => [ "最新", "ニュー" ],
  "古い" => [ "昔の", "オールド" ],
  "高い" => [ "高価", "値段が高い" ],
  "安い" => [ "低価格", "お手頃" ],
  "嬉しい" => [ "喜ばしい", "ハッピー" ],
  "悲しい" => [ "切ない", "つらい" ],
  "静か" => [ "穏やか", "しーん" ],
  "賑やか" => [ "活気がある", "にぎにぎしい" ],
  "美しい" => [ "きれい", "麗しい" ],
  "安全" => [ "安心", "セーフ" ],
  "危険" => [ "リスキー", "危ない" ]
}

synonym_rows = []
synonyms_map.each do |japanese, synonym_list|
  word = Word.find_by(japanese: japanese)
  next unless word

  synonym_list.uniq.each do |synonym_word|
    synonym_rows << {
      word_id: word.id,
      synonym_word: synonym_word,
      created_at: now,
      updated_at: now
    }
  end
end

Synonym.insert_all(synonym_rows) if synonym_rows.any?
puts "Created #{Synonym.count} synonyms"





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

puts "Creating admin custom words/tags..."
admin = User.find_by(email: "admin@example.com")

admin_extra_words = [
  { japanese: "挑戦", reading: "ちょうせん", english: "challenge" },
  { japanese: "継続", reading: "けいぞく", english: "continuation" },
  { japanese: "集中", reading: "しゅうちゅう", english: "focus" },
  { japanese: "習慣", reading: "しゅうかん", english: "habit" },
  { japanese: "効率", reading: "こうりつ", english: "efficiency" },
  { japanese: "改善", reading: "かいぜん", english: "improvement" },
  { japanese: "分析", reading: "ぶんせき", english: "analysis" },
  { japanese: "共有", reading: "きょうゆう", english: "sharing" }
]

existing_words = Word.pluck(:japanese)
new_admin_words = admin_extra_words.reject { |row| existing_words.include?(row[:japanese]) }
Word.insert_all(new_admin_words.map { |row| row.merge(created_at: now, updated_at: now) }) if new_admin_words.any?

admin_custom_tags = [
  { name: "JLPT-N3", description: "N3対策の重要語", color: "#FF7043" },
  { name: "ビジネス", description: "職場で使う語彙", color: "#546E7A" },
  { name: "会話頻出", description: "日常会話でよく使う単語", color: "#5C6BC0" }
]

admin_custom_tags.each do |tag_attrs|
  WordTag.find_or_create_by!(user_id: admin.id, name: tag_attrs[:name]) do |tag|
    tag.description = tag_attrs[:description]
    tag.color = tag_attrs[:color]
    tag.category = "custom"
  end
end

admin_word_names = [ "挑戦", "継続", "集中", "習慣", "効率", "改善", "分析", "共有", "勉強", "練習", "計画", "解決" ]
admin_word_ids = Word.where(japanese: admin_word_names).pluck(:id)

if admin_word_ids.any?
  UserWord.insert_all(
    admin_word_ids.map { |word_id| { user_id: admin.id, word_id: word_id, created_at: now, updated_at: now } }
  )
end

custom_tagging_map = {
  "JLPT-N3" => [ "勉強", "練習", "計画", "問題", "解決", "挑戦", "継続" ],
  "ビジネス" => [ "会社", "会議", "計画", "分析", "改善", "共有" ],
  "会話頻出" => [ "嬉しい", "悲しい", "大切", "行く", "来る", "話す" ]
}

custom_tagging_map.each do |tag_name, japanese_words|
  tag = WordTag.find_by(user_id: admin.id, name: tag_name)
  next unless tag

  tag.words << Word.where(japanese: japanese_words)
end

puts "\n=== 完了しました！ ==="
puts "単語:        #{Word.count}"
puts "ユーザー:        #{User.count}"
puts "クイズセッション: #{QuizSession.count}"
puts "ユーザー回答:  #{UserAnswer.count}"
puts "類義語:      #{Synonym.count}"
puts "タグ:        #{WordTag.count}"
puts "時間かかる:        #{(Time.current - total_start).round(2)}s"

