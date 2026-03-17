require "net/http"
require "json"

class JishoService
  BASE_URL = "https://jisho.org/api/v1/search/words"

  def self.fetch_random_word(level = "n3")
    uri = URI("#{BASE_URL}?keyword=%23jlpt-#{level}")
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)

    if result["data"].any?
      random_entry = result["data"].sample
      {
        word: random_entry["japanese"][0]["word"] || random_entry["japanese"][0]["reading"],
        reading: random_entry["japanese"][0]["reading"],
        meaning: random_entry["senses"][0]["english_definitions"].join(", ")
      }
    else
      nil

    end
  rescue => e
    Rails.logger.error "Jisho API error: #{e.message}"
    nil
  end
end
