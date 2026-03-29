# app/controllers/readers_controller.rb
class ReadersController < ApplicationController
  before_action :authenticate_user!

  # GET /reader
  def show
  end

  # POST /reader
  def create
    raw_text = extract_text(params)

    if raw_text.blank?
      flash.now[:alert] = "テキストを入力してください"
      return render :show
    end

    user_words  = Word.all()
    @matches    = build_word_map(user_words)
    @annotated  = annotate_text(raw_text, @matches)
    @match_count = @matches.size

    render :show
  end

  private

  # ── テキスト抽出（貼り付け or ファイル） ──
  def extract_text(params)
    if params[:file].present?
      params[:file].read.force_encoding("UTF-8")
    else
      params[:text].to_s.strip
    end
  end

  # ── ユーザーの単語をハッシュ化（高速検索用） ──
  def build_word_map(words)
    map = {}
    words.includes(:image_attachment).find_each do |word|
      # 日本語と英語の両方でマッチ
      map[word.japanese.downcase] = word if word.japanese.present?
      map[word.english.downcase]  = word if word.english.present?
    end
    map
  end

  # ── テキストにアノテーション付与 ──
  def annotate_text(text, word_map)
  return h(text) if word_map.empty?

  sorted_keys = word_map.keys.sort_by { |k| -k.length }
  pattern = Regexp.union(sorted_keys.map { |k| /#{Regexp.escape(k)}/i })

  text.gsub(pattern) do |matched|
    word = word_map[matched.downcase]
    next ERB::Util.html_escape(matched) unless word

    tooltip = [ word.reading, word.english ].reject(&:blank?).join(" - ")
    escaped_tooltip = ERB::Util.html_escape(tooltip)

    %(<span class="matched-word" data-tooltip="#{escaped_tooltip}">#{ERB::Util.html_escape(matched)}</span>)
  end
end

  def h(text)
    ERB::Util.html_escape(text)
  end
end
