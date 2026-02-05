
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
