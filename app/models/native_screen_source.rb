class NativeScreenSource < Ruflet::Rails::HtmlDsl::TemplateSource
  SCREEN_PATHS = [
    "/native", "/native/home", "/native/counter", "/native/counter_increment",
    "/native/counter_decrement", "/native/form", "/native/form_submit", "/native/widgets", "/native/device",
    *NativeController::DEVICE_FEATURES.keys.map { |slug| "/native/device_feature/#{slug}" }
  ].freeze

  def fetch(url, **options)
    # TemplateSource calls actions directly, so only demo actions may enter it.
    unless SCREEN_PATHS.include?(URI.parse(url.to_s).path)
      raise ActionController::RoutingError, "Unknown native screen"
    end

    super
  rescue URI::InvalidURIError
    raise ActionController::RoutingError, "Unknown native screen"
  end
end
