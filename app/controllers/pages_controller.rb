class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    @features = [
      {
        icon: :devices,
        title: "Single code base for any device",
        body: "Your app will look equally strong on iOS, Android, Windows, Linux, macOS, and the web."
      },
      {
        icon: :ruby,
        title: "Build an entire app in Ruby",
        body: "Build a cross-platform app without reaching for Dart, Swift, Kotlin, HTML, or JavaScript. Stay in Ruby."
      },
      {
        icon: :controls,
        title: "150+ built-in controls and services",
        body: "Layout, navigation, dialogs, charts, forms, and platform-aware services are ready to use in Ruflet."
      },
      {
        icon: :gems,
        title: "Ruby gems fit naturally",
        body: "Use the Ruby ecosystem you already trust for APIs, data work, imaging, security, and background tasks."
      },
      {
        icon: :web,
        title: "Full web support",
        body: "Target the web with the same app flow, or keep a realtime server-backed model when that fits the product better."
      },
      {
        icon: :package,
        title: "Built-in packaging",
        body: "Package for iOS, Android, Windows, Linux, macOS, and web without splitting the product into unrelated stacks."
      },
      {
        icon: :mobile,
        title: "Test on iOS and Android",
        body: "Run on real devices with the Ruflet mobile client and verify how the UI feels as you iterate."
      },
      {
        icon: :blocks,
        title: "Extensible",
        body: "Wrap platform features, compose your own controls, and build higher-level abstractions in Ruby."
      },
      {
        icon: :accessibility,
        title: "Accessible",
        body: "Ship interfaces that are easier to navigate across mobile, desktop, and web with accessibility in mind."
      }
    ]

    @hero_lines = [
      ['require', ' "ruflet"'],
      ['Ruflet.run', ' do |page|'],
      ['  page.title', ' = "Counter Demo"'],
      ['  count', ' = 0'],
      ['  count_text', ' = nil'],
      ['  count_text ||= text', '(value: count.to_s, style: { size: 40 })'],
      ['  page.add', '('],
      ['    container', '('],
      ['      expand:', ' true,'],
      ['      alignment:', ' Ruflet::MainAxisAlignment::CENTER,'],
      ['      content:', ' column('],
      ['        alignment:', ' Ruflet::MainAxisAlignment::CENTER,'],
      ['        horizontal_alignment:', ' Ruflet::CrossAxisAlignment::CENTER,'],
      ['        children:', ' ['],
      ['          text', '(value: "You have pushed the button this many times:"),'],
      ['          count_text', ''],
      ['        ]', ''],
      ['      )', ''],
      ['    ),', ''],
      ['    floating_action_button:', ' fab('],
      ['      icon', '(icon: Ruflet::MaterialIcons::ADD),'],
      ['      on_click:', ' ->(_e) do'],
      ['        count', ' += 1'],
      ['        page.update', '(count_text, value: count.to_s)'],
      ['      end', ''],
      ['    )', ''],
      ['  )', ''],
      ['end', '']
    ]
  end
end
