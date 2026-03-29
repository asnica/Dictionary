# Dictionary (日本語単語帳アプリ)

Rails 8で作られた、日本語学習向けの単語帳アプリです。  
単語登録・タグ管理・クイズ・ランキング・招待によるクレジット付与・読解補助(Reader)を1つのアプリで提供します。

## 1. 主な機能

### 1.1 認証
- メールアドレス + パスワードで新規登録/ログイン
- `has_secure_password` を使用
- ログイン後のみ主要画面へアクセス可能

### 1.2 単語管理
- 単語登録(日本語/読み/意味)
- 画像添付(Active Storage)
- AI画像生成(外部API連携、クレジット消費式)
- タグ複数付与
- 類義語複数登録
- 単語検索(日本語/英語/タグ/類義語/自分が作成した単語)
- CSVエクスポート(検索条件を反映)
- 単語の有効/無効切り替え

### 1.3 タグ管理
- システムタグ(全体共有)と個人タグ(ユーザー専用)の2種類
- 個人タグの作成/編集/削除
- タグ名検索
- `words_count` によるタグごとの単語数集計

### 1.4 クイズ
- 10問固定の4択ではなく「3択」読みクイズ
- セッション保存(中断/再開)
- 1問戻る機能
- 結果表示(正誤、未回答表示)
- 完了セッションの再挑戦

### 1.5 ランキング
- 完了クイズを対象にユーザー別最高正答率を集計
- SQLの `RANK()` ウィンドウ関数で順位計算
- ページネーション表示

### 1.6 招待機能(クレジットチャージ)
- 招待メール送信
- 招待が受理されると招待者へクレジット加算(1件あたり `3`)

### 1.7 Reader(読解補助)
- テキスト入力 or `.txt`アップロード
- 単語一致箇所をハイライト
- 一致語数を表示

## 2. 技術スタック

- Ruby 3.3.0
- Rails 8.0
- PostgreSQL
- Active Storage(画像アップロード)
- Kaminari(ページネーション)
- Faraday(外部HTTP)
- Action Mailer
- Importmap + Turbo/Stimulus
- RSpec / FactoryBot / Shoulda Matchers / Faker

## 3. 画面一覧(概略)

- ホーム: おすすめ単語表示 + 各機能への導線
- 単語一覧: 検索、編集、CSV出力、読み上げ
- 単語新規/編集: 画像、AI生成、タグ、類義語
- タグ一覧/新規/編集
- クイズ一覧 / クイズ実行 / 結果
- ランキング
- 招待管理
- Reader
- ログイン / 新規登録

## 4. データモデル設計

`db/schema.rb` (version: `2026_03_27_013404`) を基準に要点を記載します。

### 4.1 users
- 認証主体
- `image_credits` を保持(デフォルト3、0未満禁止)

### 4.2 words
- 単語本体
- `active` で公開可否管理
- 画像はActive Storageで添付

### 4.3 word_tags / word_taggings
- タグ本体 + 中間テーブル
- システムタグ(`user_id: nil`)と個人タグ(`user_id: user.id`)を共存
- ユニーク制約:
	- システムタグ名は全体で一意
	- 個人タグ名はユーザー内で一意

### 4.4 synonyms
- 単語の類義語

### 4.5 user_words
- 「誰がその単語を作成したか」を表現する紐付け
- 単語編集権限判定にも利用

### 4.6 quiz_sessions / user_answers
- クイズセッション状態
- `word_order`(出題順配列)
- `choice_order`(問題ごとの選択肢JSON)
- `current_index`, `status`, `score`
- ユーザー回答は `user_answers` に保存

### 4.7 invitations
- 招待メール管理
- `token`, `accepted_at` を保持
- 受理時に招待者へクレジット加算

## 5. 主要機能の内部フロー

### 5.1 単語の表示/検索
1. ログインユーザー作成語(`user_words`)を取得
2. 表示対象は「有効語」または「自分の作成語」
3. 条件(日本語/英語/タグ/類義語/作成者)で絞り込み
4. 関連を `includes` で先読みし一覧表示

### 5.2 単語登録
1. `words#create` で単語保存
2. `user_words` を同時に作成し作成者を記録
3. タグ/類義語も同時保存

### 5.3 AI画像生成
1. `words/generate_image` にプロンプト送信
2. `ImageGenerationService` が外部APIへリクエスト
3. 成功時にユーザークレジットをトランザクション的に減算
4. 返却されたURLを `ai_image_url` として単語保存時に添付

### 5.4 クイズ実行
1. `QuizSession.start_new!` で10語ランダム選択
2. 各語の選択肢を事前生成し `choice_order` に格納
3. `current_question` で現在問題をJSON返却
4. `user_answers#create` で回答保存し `next!`
5. 最終問題後に `complete!` でスコア確定

### 5.5 ランキング集計
- 完了セッションの正答率からユーザー別最高値を集計
- `RANK() OVER (...)` で順位を付与

### 5.6 Reader
1. 入力テキスト(貼り付け/ファイル)を受け取る
2. 単語辞書を構築(日本語/英語キー)
3. 一致語をHTMLアノテーションして表示

## 6. ルーティング概要

- `root` : ホーム
- `users` : 新規登録
- `sessions` : ログイン/ログアウト
- `word_tags` : タグCRUD
- `words` : 単語CRUD + `export_csv` + `generate_image`
- `quiz_sessions` : 一覧/作成/実行/結果/再挑戦/前問移動
- `ranking` : ランキング表示
- `invitations` : 招待一覧/作成
- `reader` : Reader表示/解析

## 7. セットアップ手順(ローカル)

### 7.1 前提
- Ruby 3.3.x
- PostgreSQL 16 付近
- Bundler

### 7.2 DB起動(docker-compose利用)
```bash
docker compose up -d postgres
```

### 7.3 依存インストール
```bash
bundle install
```

### 7.4 DB作成/マイグレーション
```bash
bin/rails db:prepare
```

### 7.5 起動
```bash
bin/dev
```

`bin/dev` は現在 `bin/rails server` を実行します。

## 8. 環境変数

### 8.1 画像生成API
- `IMAGE_API_BASE_URL`
- `IMAGE_API_KEY`

### 8.2 メール関連
- `GMAIL_USERNAME` (送信元アドレス)
- `MAILGUN_USER` (production)
- `MAILGUN_PASSWORD` (production)

## 9. 開発/テスト

### 9.1 テスト実行
```bash
bundle exec rspec
```

または

```bash
bin/rails test
```

### 9.2 静的解析
```bash
bin/brakeman
bin/rubocop
```

## 10. シードデータ

- `db/seeds.rb`: 単語、タグ、ユーザー、クイズセッションを大量生成するスクリプト
- `db/seeds_test.rb`: テスト用に単語/ユーザー/クイズを生成

注: シードは大量データを投入するため、ローカル実行時は所要時間に注意してください。

## 11. 既知の注意点

- 招待トークン受理用メソッド(`UsersController#accept_invitation`)は存在しますが、登録処理から直接呼ばれていないため、招待受理の自動反映は追加実装が必要です。
- Reader用の `app/javascript/reader_tooltip.js` は、現在のビュー側データ属性と整合しないため、必要に応じて接続方法の見直しが必要です。
- `db/seeds.rb` には `Wordtag` という定数名があり、`WordTag` への修正が必要です。

## 12. デプロイ

- `Dockerfile` はKamal運用を想定した構成
- productionではSMTP(Mailgun)設定が必要

---

必要であれば次のステップとして、READMEにER図やシーケンス図を追加できます。


