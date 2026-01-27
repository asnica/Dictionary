# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
return if Rails.env.test?

system_tags = [
  { name: "N5", color: "#4CAF50" },
  { name: "N4", color: "#8BC34A" },
  { name: "N3", color: "#CDDC39" },
  { name: "N2", color: "#FFC107" },
  { name: "N1", color: "#FF5722" }
]

system_tags.each do |attrs|
  WordTag.find_or_create_by!(name: attrs[:name], user_id: nil) do |tag|
        tag.category = "system"
        tag.color = attrs[:color]
  end
end
