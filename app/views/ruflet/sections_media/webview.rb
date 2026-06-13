# frozen_string_literal: true

module Showcase
  module SectionsMedia
    def build_webview(page, _status)
      # On the web the WebView becomes an <iframe>, which only embeds pages that
      # allow framing. ruflet.dev (like most sites) sends
      # X-Frame-Options: SAMEORIGIN, so it can be framed only from its OWN
      # origin. So on the web we load the app's own origin (backend_url) — that
      # is ruflet.dev in production and the local host in development, and
      # same-origin always frames. Native loads ruflet.dev directly (no iframe
      # restriction).
      url = "https://rubyonrails.org/"
       

      column(
        expand: true,
        spacing: 8,
        children: [
          text("WebView showing #{url}"),
          container(
            expand: true,
            border_radius: 8,
            content: web_view(url: url, expand: true)
          )
        ]
      )
    end
  end
end
