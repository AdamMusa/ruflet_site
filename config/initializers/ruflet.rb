Ruflet::Rails.configure do |config|
  config.backend_url = ENV.fetch("RUFLET_BACKEND_URL") do
    Rails.env.production? ? "https://ruflet.dev" : "http://localhost:#{ENV.fetch("PORT", 3000)}"
  end
  config.app_name = "Ruflet Native Demo"
  config.icon_launcher = Rails.root.join("app/assets/images/icon.png")

  config.services = [
    { camera: { description: "Try the native camera example." } },
    { microphone: { description: "Record audio in the native demo." } },
    { location: { description: "Try the native location and map examples." } },
    { motion: { description: "Try the native motion sensor examples." } }
  ]

  config.extensions = %w[
    audio audio_recorder camera charts code_editor flashlight geolocator map
    permission_handler rive secure_storage spinkit video webview
  ]
end
