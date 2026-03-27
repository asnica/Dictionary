class ImageGenerationService
  Result = Struct.new(:success?, :image_url, :error, keyword_init: true)

  def initialize(user:, prompt:)
    @user = user
    @prompt = prompt.to_s.strip
  end

   def call
    return failure("プロンプトを入力してください")  if @prompt.blank?
    return failure("クレジットが不足しています")     unless @user.can_generate_image?

    image_url = request_image!(@prompt)

    @user.with_lock do
      return failure("クレジットが不足しています") unless @user.can_generate_image?
      @user.consume_credit!
    end

    Result.new(success?: true, image_url: image_url)
  rescue StandardError => e
    Rails.logger.error("[ImageGenerationService] #{e.class}: #{e.message}")
    failure("画像生成に失敗しました")
  end

  def failure(message)
    Result.new(success?: false, error: message)
  end

  def request_image!(prompt)
    conn = Faraday.new(url: ENV.fetch("IMAGE_API_BASE_URL")) do |f|
      f.request :json
      f.adapter Faraday.default_adapter
      f.options.timeout = 30
      f.options.open_timeout = 10
    end

    resp = conn.post("/v1/images/generations") do |req|
      req.headers["Authorization"] = "Bearer #{ENV.fetch("IMAGE_API_KEY")}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        model: "dall-e-3",
        prompt: prompt,
        size: "1024x1024" }
    end

    raise "APIエラー: #{resp.status}" unless resp.success?

    body = JSON.parse(resp.body)
    body.dig("data", 0, "url") || raise("画像URLが取得できませんでした")
  end
end
