require "test_helper"

# Charts, canvas shapes, maps, media, web view, code editor, color pickers and
# ads: every control is documented, and no generated property, event or method
# line falls back to the placeholder text DocsCatalog writes for an unknown
# attribute. Like docs_coverage_test.rb it reads only the site's own files.
class DocsExtensionControlsTest < ActiveSupport::TestCase
  CONTROLS = %w[
    arc audio banner-ad bar-chart bar-chart-group bar-chart-rod bar-chart-rod-stack-item block-picker
    candlestick-chart candlestick-chart-spot canvas chart-axis chart-axis-label circle circle-layer
    circle-marker code-editor color color-picker fill hue-ring-picker image-source-attribution
    interstitial-ad line line-chart line-chart-data line-chart-data-point lottie map marker marker-layer
    material-picker multiple-choice-block-picker native-ad oval path pie-chart pie-chart-section points
    polygon-layer polygon-marker polyline-layer polyline-marker radar-chart radar-chart-title radar-data-set
    radar-data-set-entry rect rich-attribution rive scatter-chart scatter-chart-spot shadow
    simple-attribution slide-picker text-source-attribution tile-layer video web-view
  ].map { |name| "control-#{name}" }.freeze

  FALLBACK_PROPERTY = /\A- `([a-z_0-9]+)` — Sets the [a-z0-9 ]+ property\./
  GENERIC_EVENT = /\A- `(on_[a-z_0-9]+)` — Fired (?:on [a-z0-9 ]+|when [a-z0-9 ]+ occurs)\.\s*\z/

  # Hand-written sentences about main-only behavior on this group's pages.
  # Each must stay and keep the next-release marker in its paragraph or item.
  PINNED_PROSE_MARKERS = {
    "control-web-view" => [ "changing `url` with `page.update` also navigates", "With the next release the error comes at once." ],
    "control-code-editor" => [ "with the next release `:atom_one_dark` works too", "a `value` you set from Ruby also fires it" ],
    "control-color-picker" => [ "the client also writes the pick back to `color`" ],
    "control-block-picker" => [ "Changing `color` from Ruby after the picker is shown" ],
    "control-material-picker" => [ "Changing `color` from Ruby after the picker is shown" ],
    "control-multiple-choice-block-picker" => [ "Changing `colors` from Ruby after the picker is shown" ],
    "charts-and-canvas" => [
      "On 0.0.23 the canvas has no `capture` method.",
      "With the next release a chart `tooltip` styles the bubble",
      "With the next release `spots` is a list of `{ bar_index:, spot_index: }` hashes",
      "release `group_spacing` also sets the space between groups",
      "With the next release `selected` keeps the bubble of a candle"
    ],
    "control-line-chart" => [ "With the next release `event.data[:spots]` also says which points were touched" ],
    "control-scatter-chart" => [ "With the next release a spot with its own `tooltip:` text shows it in a bubble." ],
    "control-candlestick-chart" => [ "With the next release a candle with its own `tooltip:` text shows it in a bubble." ],
    "control-bar-chart-rod" => [ "replaces the value in the bar's touch bubble" ],
    "control-line-chart-data-point" => [ "replaces the value in the point's touch bubble" ],
    "control-scatter-chart-spot" => [ "gives the spot a touch bubble" ],
    "control-candlestick-chart-spot" => [ "gives the candle a touch bubble" ],
    "control-lottie" => [ "the next release only applies the change" ],
    "extensions" => [ "With the next release both spellings" ]
  }.freeze

  # Generated lines whose 0.0.23 client does only part of what they say: the
  # 0.0.23 statement stays in the description and the main-only part follows
  # as a config/next_release.json "client_ignored" note with the marker.
  PINNED_PARTIAL_LINES = [
    [ "control-bar-chart", "properties", "tooltip", "On 0.0.23 a chart with `tooltip` set shows no bubble at all", "the touched bar's own `tooltip` text, or its value." ],
    [ "control-line-chart", "properties", "tooltip", "On 0.0.23 a chart with `tooltip` set shows no bubble at all", "each touched point's own `tooltip` text, or its `y` value." ],
    [ "control-line-chart", "events", "on_event", "`{ bar_index: line, spot_index: point }`", "On 0.0.23 each entry of `spots` arrives as an empty String, so only `type` is usable." ],
    [ "control-scatter-chart", "properties", "tooltip", "On 0.0.23 scatter charts show no bubble", "a spot with its own `tooltip` text shows it in this bubble." ],
    [ "control-candlestick-chart", "properties", "tooltip", "On 0.0.23 candlestick charts show no bubble", "a candle with its own `tooltip` text shows it in this bubble." ],
    [ "control-scatter-chart-spot", "properties", "selected", "On 0.0.23 scatter charts show no bubble", "a selected spot with its own `tooltip` text shows it permanently." ],
    [ "control-candlestick-chart-spot", "properties", "selected", "On 0.0.23 candlestick charts show no bubble", "a selected candle with its own `tooltip` text shows it permanently." ]
  ].freeze

  # Pages of the group with hand-written Ruby: every event payload hash the
  # server hands a handler has symbol keys (ConnectionProtocol#normalize_event_data).
  GUIDE_PAGES = %w[charts-and-canvas maps extensions extension-authoring qrcode-scanner].freeze
  EXTENSION_PAGES = %w[ads audio charts code-editor color-pickers lottie map rive video webview].map { |key| "extension-#{key}" }.freeze

  test "every control of the group is documented" do
    catalog = DocsCatalog.control_catalog.map { |control| control[:slug] }

    assert_empty CONTROLS - catalog, "The catalog no longer lists these controls; update CONTROLS"
    undocumented = CONTROLS.reject do |slug|
      DocsCatalog::SOURCE_ROOT.join("#{slug.tr('-', '_')}.md").exist? || DocsCatalog.control_docs.key?(slug)
    end
    assert_empty undocumented
  end

  test "no generated line of the group falls back to placeholder text" do
    placeholders = CONTROLS.flat_map do |slug|
      DocsCatalog.find(slug).content.lines.filter_map do |line|
        "#{slug}: #{line.strip}" if line.match?(FALLBACK_PROPERTY) || line.match?(GENERIC_EVENT)
      end
    end

    assert_empty placeholders, "Describe these in config/property_descriptions.json widget_overrides:\n#{placeholders.join("\n")}"
  end

  test "every method of the group is described" do
    bare = CONTROLS.flat_map do |slug|
      control = DocsCatalog.control_catalog.find { |entry| entry[:slug] == slug }
      Array(control[:methods]).filter_map do |method|
        name = method[:name].to_s
        "#{slug} #{name}" unless DocsCatalog.find(slug).content.match?(/^- `#{Regexp.escape(name)}(?:\(|`).* — /)
      end
    end

    assert_empty bare, "Add a config/property_descriptions.json method_notes entry for: #{bare.join(', ')}"
  end

  test "the web view page documents the navigation events whatever the catalog lists" do
    prose = DocsCatalog::SOURCE_ROOT.join("control_web_view.md").read

    %w[on_page_started on_page_ended on_url_change].each do |event|
      assert_match(/^- `#{event}` — /, prose, "control_web_view.md must keep documenting #{event}")
    end
  end

  test "services of the group are registered as services in their examples" do
    assert_includes example("control-audio"), "page.audio("
    refute_match(/page\.add\(\s*player\b/, example("control-audio"))
    assert_includes example("control-interstitial-ad"), "page.add_service(ad)"
  end

  test "hand-written sentences about main-only behavior keep the marker" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    PINNED_PROSE_MARKERS.each do |slug, phrases|
      chunks = DocsCatalog.find(slug).then { |entry| (entry.content || entry.source.read) }
                          .split("\n## Complete API\n", 2).first.split(/\n(?=- |\n)/).map(&:squish)
      phrases.each do |phrase|
        chunk = chunks.find { |candidate| candidate.include?(phrase) }

        assert chunk, "#{slug} no longer says #{phrase.inspect}"
        assert_includes chunk, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
  end

  test "generated lines that partly work on 0.0.23 keep both statements" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    PINNED_PARTIAL_LINES.each do |slug, kind, name, released, next_release|
      line = generated_line(slug, kind, name)

      assert_includes line, released, "#{slug} #{kind} #{name} lost what 0.0.23 does"
      assert_includes line, "#{next_release} #{marker}.", "#{slug} #{kind} #{name} lost its next-release note"
    end
  end

  # On 0.0.23 and on main the server symbolizes the keys of every event payload
  # hash, so a string key reads nil (an example then raises or does nothing).
  test "pages of the group read event payloads with symbol keys" do
    string_key = /\bevent\.data\[["']|\b(?:point|spot|touched|coordinates)\[["']/
    offenders = (CONTROLS + GUIDE_PAGES + EXTENSION_PAGES).filter_map do |slug|
      entry = page(slug)
      slug if (entry.content || entry.source.read).match?(string_key)
    end

    assert_empty offenders, "Read payload hashes with symbol keys, for example `event.data[:coordinates]`"
  end

  test "the line chart example skips the spots 0.0.23 sends as empty Strings" do
    assert_includes example("control-line-chart"), "Array(event.data[:spots]).find { |touched| touched.is_a?(Hash) }"
  end

  # Corrections an earlier review made, which run either way, so only a test
  # keeps them: names and arguments the 0.0.23 client reads, and colors it draws.
  test "pages of the group keep the property names and colors the clients read" do
    guide = DocsCatalog::SOURCE_ROOT.join("charts_and_canvas.md").read
    web_view = DocsCatalog::SOURCE_ROOT.join("control_web_view.md").read

    refute_includes guide, "rod_stack_items", "0.0.23 reads a rod's segments from `stack_items` only"
    guide.scan(/path_quadratic_to\([^)]*\)/).each do |call|
      assert_includes call, "w:", "Without `w:` the client draws #{call} as a straight line"
    end
    refute_match(/enable_javascript/, web_view, "No client reads `enable_javascript`; call `set_javascript_mode`")
    %w[markerlayer polygonmarker].each do |type|
      crafted = Array(DocsCatalog.send(:crafted_control_example, type)).join("\n")

      refute_match(/"#\h{8}"/, crafted, "#{type}: write a translucent color as \"#rrggbb,opacity\", not alpha last")
      refute_match(/color: :[a-z]+_\d/, crafted, "#{type}: the clients draw no color for a name with an underscore, such as :blue_600")
    end
  end

  test "the ads page says no generated client carries an AdMob app id" do
    platforms = DocsCatalog::EXTENSION_CATALOG.find { |extension| extension[:key] == "ads" }.fetch(:platforms)

    assert_includes platforms, "the Android manifest of the client `ruflet build` generates has none"
    assert_includes platforms, "iOS and macOS builds remove the sample id"
  end

  # Ruflet main's client reads BarChart `group_spacing` and 0.0.23's does not.
  # The catalog lists it, and ChartAxis `tooltip`, after the next API sync:
  # both are described already, and group_spacing must then be marked.
  test "lines the next API sync adds are described, and group_spacing gets marked" do
    overrides = JSON.parse(Rails.root.join("config/property_descriptions.json").read).fetch("widget_overrides")

    assert overrides.dig("barchart", "group_spacing"), "Describe BarChart group_spacing in widget_overrides"
    assert_equal "Has no effect: an axis draws no tooltip.", overrides.dig("chartaxis", "tooltip")
    control = DocsCatalog.control_catalog.find { |entry| entry[:slug] == "control-bar-chart" }
    # Nothing to mark once the release ships and config/next_release.json is emptied.
    return unless control[:properties].include?("group_spacing") && DocsCatalog.next_release[:client_ignored].any?

    assert_includes generated_line("control-bar-chart", "properties", "group_spacing"),
                    "The 0.0.23 client ignores it. #{DocsCatalog::NEXT_RELEASE_MARKER}.",
                    "List group_spacing for control-bar-chart under client_ignored in config/next_release.json"
  end

  private

  def example(slug)
    Array(DocsCatalog.control_docs.dig(slug, "example")).join("\n")
  end

  # DocsCatalog.find falls back to the first page for an unknown slug.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end

  # The one generated "- `name` — ..." line of a kind on a generated control page.
  def generated_line(slug, kind, name)
    heading = { "properties" => "## Properties", "events" => "## Events", "methods" => "## Methods" }.fetch(kind)
    section = page(slug).content.split(/^#{heading}$/, 2).last.split(/^## /, 2).first
    lines = section.lines.select { |line| line.start_with?("- `#{name}` — ", "- `#{name}(") }

    assert_equal 1, lines.size, "#{slug} should render one #{kind} line for #{name}"
    lines.first
  end
end
