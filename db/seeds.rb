User.find_or_create_by!(email_address: "admin@ruflet.dev") do |user|
  user.password = "password123!"
  user.password_confirmation = "password123!"
  user.admin = true
end
