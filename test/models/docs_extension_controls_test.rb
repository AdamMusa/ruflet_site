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
    "control-web-view" => [ "changing `url` with `page.update` also navigates" ],
    "control-code-editor" => [ "with the next release `:atom_one_dark` works too", "a `value` you set from Ruby also fires it" ],
    "control-color-picker" => [ "the client also writes the pick back to `color`" ],
    "control-block-picker" => [ "Changing `color` from Ruby after the picker is shown" ],
    "control-material-picker" => [ "Changing `color` from Ruby after the picker is shown" ],
    "control-multiple-choice-block-picker" => [ "Changing `colors` from Ruby after the picker is shown" ],
    "charts-and-canvas" => [ "On 0.0.23 the canvas has no `capture` method." ],
    "extensions" => [ "With the next release both spellings" ]
  }.freeze

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

  private

  def example(slug)
    Array(DocsCatalog.control_docs.dig(slug, "example")).join("\n")
  end
end
