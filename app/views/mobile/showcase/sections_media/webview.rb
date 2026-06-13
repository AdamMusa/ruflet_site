# frozen_string_literal: true

module Showcase
  module SectionsMedia
    def build_webview(page, _status)
      # The native webview (iOS / Android / macOS / Windows / Linux) loads any
      # site directly. On the web the control becomes an <iframe>, which only
      # renders pages that permit embedding — many sites (ruflet.dev included)
      # block it via X-Frame-Options / CSP and would appear blank. So load an
      # embed-friendly page on the web and the real site on native: the WebView
      # always shows something.
      platform = page.client_details["platform"].to_s
      url = platform == "web" ? "https://example.com/" : "https://ruflet.dev/"

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
