require "test_helper"
require "prism"

# Every Ruflet control and service the reference lists must be documented.
# The test reads only the site's own files (config/*.json, app/content/docs and
# DocsCatalog), so it runs offline and without a Ruflet checkout.
class DocsCoverageTest < ActiveSupport::TestCase
  # Controls that still have only a generated page. The list may only shrink:
  # document a control (a page or a config/control_docs.json entry) and then
  # remove it here. A listed control that gains docs does not fail the test,
  # so pages can land in any order.
  PENDING_CONTROLS = %w[
    control-arc control-audio control-auto-complete-suggestion control-autofill-group
    control-banner-ad control-bar-chart control-bar-chart-group control-bar-chart-rod
    control-bar-chart-rod-stack-item control-block-picker control-candlestick-chart
    control-candlestick-chart-spot control-canvas control-chart-axis control-chart-axis-label
    control-circle control-circle-layer control-circle-marker control-color control-color-picker
    control-cupertino-checkbox control-cupertino-picker control-cupertino-radio
    control-cupertino-slider control-cupertino-timer-picker control-dropdown-option control-fill
    control-form control-form-row control-hue-ring-picker control-image-source-attribution
    control-interstitial-ad control-line control-line-chart control-line-chart-data
    control-line-chart-data-point control-lottie control-map control-marker control-marker-layer
    control-material-picker control-multiple-choice-block-picker control-native-ad
    control-option control-oval control-path control-picker control-pie-chart
    control-pie-chart-section control-points control-polygon-layer control-polygon-marker
    control-polyline-layer control-polyline-marker control-radar-chart control-radar-chart-title
    control-radar-data-set control-radar-data-set-entry control-rect control-rich-attribution
    control-scatter-chart control-scatter-chart-spot control-shadow control-simple-attribution
    control-slide-picker control-text-source-attribution control-tile-layer control-timer-picker
    control-video
  ].freeze

  GENERIC_SERVICE_SUMMARY = /\AComplete `page\.\w+` service reference\.\z/

  test "every control has a prose page or a curated summary and example" do
    undocumented = DocsCatalog.control_catalog.map { |control| control[:slug] }.reject { |slug| documented_control?(slug) }
    missing = undocumented - PENDING_CONTROLS

    assert_empty missing, <<~MESSAGE
      These controls have no documentation: #{missing.join(', ')}.
      Add app/content/docs/<slug with underscores>.md (see control_list_tile.md), or an
      entry in config/control_docs.json with a "summary" and an "example" (a list of lines).
    MESSAGE
  end

  test "pending controls are still in the catalog" do
    stale = PENDING_CONTROLS - DocsCatalog.control_catalog.map { |control| control[:slug] }

    assert_empty stale, "Remove these slugs from PENDING_CONTROLS, the catalog no longer lists them: #{stale.join(', ')}"
  end

  test "curated control docs have a summary and an example for a cataloged control" do
    slugs = DocsCatalog.control_catalog.map { |control| control[:slug] }

    DocsCatalog.control_docs.each do |slug, docs|
      assert_includes slugs, slug, "config/control_docs.json documents #{slug}, which the catalog does not list"
      assert docs["summary"].present?, "#{slug} needs a summary in config/control_docs.json"
      assert Array(docs["example"]).any?(&:present?), "#{slug} needs an example in config/control_docs.json"
      next if DocsCatalog::SOURCE_ROOT.join("#{slug.tr('-', '_')}.md").exist?

      assert_includes page(slug).content, docs["summary"]
    end
  end

  test "every service has an example and a one-sentence summary" do
    DocsCatalog.service_catalog.fetch(:services).each do |service|
      helper = service.fetch(:helper)
      summary = DocsCatalog::SERVICE_SUMMARIES[helper].to_s
      entry = page("service-#{helper.tr('_', '-')}")

      assert DocsCatalog::SERVICE_EXAMPLES[helper].present?, "Add a #{helper} example to DocsCatalog::SERVICE_EXAMPLES"
      assert summary.present?, "Add a #{helper} summary to DocsCatalog::SERVICE_SUMMARIES"
      assert_match(/\A[A-Z][^.]*[^.\s]\.\z/, summary, "The #{helper} summary must be one sentence")
      refute_match GENERIC_SERVICE_SUMMARY, summary
      assert_equal summary, entry.summary
    end
  end

  test "curated examples and Ruby blocks on control and service pages compile" do
    sources = {}
    DocsCatalog.control_docs.each { |slug, docs| sources["config/control_docs.json #{slug}"] = Array(docs["example"]).join("\n") }
    DocsCatalog::SERVICE_EXAMPLES.each { |helper, example| sources["SERVICE_EXAMPLES #{helper}"] = example }
    DocsCatalog.extension_catalog.each { |extension| sources["EXTENSION_CATALOG #{extension.fetch(:key)}"] = extension.fetch(:example) }
    catalog_pages.each do |entry|
      entry.content.scan(/^```ruby\n(.*?)^```/m).flatten.each_with_index do |block, index|
        sources["#{entry.slug} Ruby block #{index + 1}"] = block
      end
    end

    failures = sources.filter_map do |name, code|
      RubyVM::InstructionSequence.compile(code)
      nil
    rescue SyntaxError => error
      "#{name}: #{error.message.lines.first.strip}"
    end

    assert_operator sources.size, :>, DocsCatalog.control_catalog.size
    assert_empty failures, "These examples do not compile:\n#{failures.join("\n")}"
  end

  test "next-release pages exist and carry the callout" do
    config = JSON.parse(Rails.root.join("config/next_release.json").read)
    control_slugs = DocsCatalog.control_catalog.map { |control| control[:slug] }
    service_helpers = DocsCatalog.service_catalog.fetch(:services).map { |service| service[:helper] }

    assert_includes DocsCatalog::NEXT_RELEASE_MARKER, "not in #{config.fetch('released')})"
    assert_empty config.fetch("controls") - control_slugs, "config/next_release.json lists controls the catalog does not have"
    assert_empty config.fetch("services") - service_helpers, "config/next_release.json lists services the catalog does not have"

    pages = config.fetch("controls") + config.fetch("services").map { |helper| "service-#{helper.tr('_', '-')}" }
    pages.each do |slug|
      content = page(slug).content
      intro = content.split(/^## /).first
      html = MarkdownRenderer.render(content).html

      assert_includes intro, "> #{DocsCatalog::NEXT_RELEASE_MARKER}", "#{slug} needs the next-release callout under its H1"
      assert_equal 1, content.scan("> #{DocsCatalog::NEXT_RELEASE_MARKER}").size, "#{slug} shows the callout more than once"
      assert_match %r{<blockquote><p><strong>Requires the next Ruflet release</strong> \(on <code>main</code>, not in 0\.0\.23\)}, html
    end
  end

  test "pages that work on the published release do not get the callout" do
    config = JSON.parse(Rails.root.join("config/next_release.json").read)
    listed = config.fetch("controls") + config.fetch("services").map { |helper| "service-#{helper.tr('_', '-')}" }

    flagged = catalog_pages.reject { |entry| listed.include?(entry.slug) }.select do |entry|
      entry.content.split(/^## /).first.include?("> #{DocsCatalog::NEXT_RELEASE_MARKER}") && !DocsCatalog::SOURCE_ROOT.join("#{entry.slug.tr('-', '_')}.md").exist?
    end

    assert_empty flagged.map(&:slug), "Only pages listed in config/next_release.json get the generated callout"
  end

  test "next-release members name properties, events and methods of 0.0.23 controls" do
    config = JSON.parse(Rails.root.join("config/next_release.json").read)
    catalog = DocsCatalog.control_catalog.index_by { |control| control[:slug] }

    assert_empty config.fetch("design_client_ignored").keys - DocsCatalog::NEXT_RELEASE_DESIGN_PLATFORMS.keys
    listed_twice = next_release_lists(config).group_by { |_list, slug, kind, name| [ slug, kind, name ] }.select { |_key, entries| entries.size > 1 }
    assert_empty listed_twice.keys, "Each line may appear in one next-release list only: #{listed_twice.keys.inspect}"

    next_release_lists(config).each do |list, slug, kind, name|
      control = catalog[slug]

      assert control, "config/next_release.json #{list} lists #{slug}, which the catalog does not have"
      refute_includes config.fetch("controls"), slug, "#{slug} is a next-release page; its callout already covers every line"
      assert_includes %w[properties events methods], kind
      known = Array(control[kind.to_sym]).map { |entry| entry.is_a?(Hash) ? entry[:name].to_s : entry.to_s }
      assert_includes known, name, "#{list} #{slug} #{kind} names #{name}, which the catalog does not list"
    end
  end

  test "generated property, event and method lines carry the inline marker exactly when listed" do
    config = JSON.parse(Rails.root.join("config/next_release.json").read)
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    wrong = []

    lists = next_release_lists(config)

    DocsCatalog.control_catalog.reject { |control| config.fetch("controls").include?(control[:slug]) }.each do |control|
      slug = control[:slug]
      listed = lists.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(_list, entry_slug, kind, name), names|
        names[kind] << name if entry_slug == slug
      end
      seen = Hash.new { |hash, key| hash[key] = [] }

      generated_api_lines(page(slug).content).each do |kind, name, line|
        seen[kind] << name
        expected = listed[kind].include?(name)
        wrong << "#{slug} #{kind} #{name}: #{expected ? 'missing' : 'unexpected'} marker" if line.include?(marker) != expected
      end
      listed.each do |kind, names|
        (names - seen[kind]).each { |name| wrong << "#{slug} #{kind} #{name}: listed but not rendered" }
      end
    end

    assert_empty wrong, wrong.join("\n")
  end

  # Lines a review found wrong, pinned so a config edit cannot silently undo
  # the fix: [slug, kind, name, the note the line must carry before the marker].
  PINNED_NEXT_RELEASE_LINES = [
    [ "control-data-table", "properties", "show_checkbox_column", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-data-table", "properties", "vertical_lines", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-data-table", "properties", "horizontal_lines", "The 0.0.23 client ignores it." ],
    [ "control-data-table", "events", "on_select_all", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-data-row", "events", "on_select_change", "In a `data_table` on iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-banner", "events", "on_dismiss", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-bottom-sheet", "properties", "show_drag_handle", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-bottom-sheet", "properties", "fullscreen", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-progress-ring", "properties", "year_2023", "The 0.0.23 client ignores it." ],
    [ "control-progress-ring", "properties", "semantics_label", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-checkbox", "properties", "spacing", "On Android, web, Windows and Linux, the 0.0.23 client ignores it." ],
    [ "control-context-menu", "events", "on_select", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-popup-menu-button", "events", "on_cancel", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-search-bar", "events", "on_tap_outside_bar", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-search-bar", "methods", "open_view", "On iOS and macOS, the 0.0.23 client does not run it." ],
    [ "control-search-bar", "methods", "close_view", "On iOS and macOS, the 0.0.23 client does not run it." ],
    [ "control-slider", "properties", "autofocus", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-slider", "events", "on_focus", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-slider", "events", "on_blur", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-icon-button", "properties", "selected_icon", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-icon-button", "properties", "selected_icon_color", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-icon-button", "properties", "disabled_color", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-icon-button", "properties", "enable_feedback", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-icon-button", "properties", "style", "On Android, web, Windows and Linux, the 0.0.23 client ignores it." ],
    [ "control-list-tile", "properties", "selected", "On iOS and macOS, the 0.0.23 client ignores it." ],
    [ "control-list-tile", "events", "on_long_press", "On iOS and macOS, the 0.0.23 client never sends it." ],
    [ "control-list-tile", "properties", "toggle_inputs", "On iOS and macOS, the 0.0.23 client toggles a `switch` or `checkbox` in the row, but not a `radio`." ],
    [ "control-bottom-sheet", "properties", "bgcolor", "On iOS and macOS, the 0.0.23 client uses it only when the content is a `picker`, `timer_picker` or `date_picker`; other content is shown without a sheet panel." ],
    [ "control-cupertino-bottom-sheet", "properties", "padding", "On iOS and macOS, the 0.0.23 client uses it only when the content is a `picker`, `timer_picker` or `date_picker`; other content is shown without a sheet panel." ],
    [ "control-app-bar", "properties", "large", "On Android, web, Windows and Linux, the 0.0.23 client ignores it." ],
    [ "control-app-bar", "properties", "trailing", "On Android, web, Windows and Linux, the 0.0.23 client ignores it." ],
    [ "control-cupertino-sliding-segmented-button", "properties", "bgcolor", "The 0.0.23 client ignores it." ],
    [ "control-cupertino-sliding-segmented-button", "properties", "thumb_color", "The 0.0.23 client ignores it." ],
    [ "control-cupertino-sliding-segmented-button", "properties", "proportional_width", "The 0.0.23 client ignores it." ]
  ].freeze

  # Lines that must stay unmarked: they work with 0.0.23, or (ContextMenu.open
  # on iOS and macOS) main does not run them either. PopupMenuButton on_select
  # is not one of them: with 0.0.23 on iOS and macOS the item wins the tap and
  # the sheet's row handler, which sends `select`, never runs (a widget test of
  # template main; ruflet-engine 99b0f633 fixed it).
  PINNED_RELEASED_LINES = [
    [ "control-reorderable-list-view", "events", "on_scroll" ],
    [ "control-reorderable-list-view", "properties", "scroll_interval" ],
    [ "control-context-menu", "methods", "open" ]
  ].freeze

  # Hand-written sentences that describe main-only behavior and must say so.
  # A phrase may span a line break in the Markdown source.
  PINNED_PROSE_MARKERS = {
    "control-data-table" => [
      "the 0.0.23 client draws no checkbox column",
      "the 0.0.23 client also ignores `vertical_lines`",
      "there the 0.0.23 client shows no checkboxes"
    ],
    "control-banner" => [ "On iOS and macOS, the 0.0.23 client never sends it.", "`surface_tint_color` tints the banner by its elevation" ],
    "control-bottom-sheet" => [
      "`fullscreen` — on iOS and macOS these need the",
      "`maintain_bottom_view_insets_padding` — let a tall sheet grow",
      "With 0.0.23 other content is shown without a panel or background"
    ],
    "control-progress-ring" => [ "`false` gives the newer Material look", "the iOS name for `value`" ],
    "control-expansion-panel-list" => [ "`expand_icon_color` — the color of the arrow icons", "`scroll`, `auto_scroll`, `scroll_interval` and `on_scroll`" ],
    "control-popup-menu-button" => [ "`on_cancel` when the sheet closes without a choice" ],
    "control-search-bar" => [ "On iOS and macOS, `open_view` focuses the bar", "with 0.0.23 both do nothing there" ],
    "control-list-tile" => [
      "there `selected` only tells screen readers",
      "toggles a `switch` or `checkbox` in the row, but not a `radio`",
      "`on_long_press` fires on iOS and macOS only with the next release",
      "its `padding` keyword takes effect only with the next release"
    ],
    "control-cupertino-list-tile" => [ "`padding` takes effect only with the next release" ],
    "control-cupertino-activity-indicator" => [ "there the 0.0.23 client also ignores `progress` and always spins" ],
    "control-cupertino-bottom-sheet" => [ "which `bottom_sheet` accepts" ],
    "control-action-sheet" => [ "the `bottom_sheet` draws the action sheet on its own panel" ],
    "control-cupertino-action-sheet" => [ "the bottom sheet draws it on its own panel" ],
    "control-cupertino-sliding-segmented-button" => [
      "comes from the `sliding` flag this helper sends",
      "on iOS and macOS, size each segment to its content",
      "the colors of the track and of the sliding thumb"
    ],
    "control-cupertino-date-picker" => [ "drawing it in place with `page.add`" ]
  }.freeze

  # Hand-written sentences that say which platforms a line applies to. They
  # hold on 0.0.23 and on main, so they carry no marker, but a review found the
  # page wrong without them.
  PINNED_PROSE_QUALIFIERS = {
    "control-data-table" => [
      "`event.data[:asc]` is the new direction on Android, web, Windows and Linux.",
      "On iOS and macOS it is the table's current `sort_ascending`"
    ],
    "control-list-tile" => [
      "`dense` / `is_three_line` — Android, web, Windows and Linux only",
      "`hover_color` — Android, web, Windows and Linux only",
      "`shape` — Android, web, Windows and Linux only"
    ],
    "control-bottom-sheet" => [ "`shape` / `elevation` — Android, web, Windows and Linux only", "`padding` / `height` — iOS and macOS only",
      "`:surfacecontainerlow` is the color the Material sheet itself uses" ],
    "control-alert-dialog" => [ "`inset_animation` — how the alert moves when the keyboard opens", "Android, web, Windows and Linux ignore those two flags." ],
    "control-action-sheet" => [ "Tapping an action does not close the sheet", "With 0.0.23 the sheet floats over the dimmed page" ],
    "control-snack-bar" => [
      "On iOS and macOS every snackbar closes after `duration` unless you pass",
      "tapping the action does not close it",
      "showing the same `snack_bar` a second time does nothing there"
    ],
    "control-expansion-tile" => [ "On iOS and macOS it is redrawn only when Ruby sets `expanded`" ],
    "control-expansion-panel-list" => [ "On iOS and macOS it is redrawn only when Ruby updates the list" ],
    "control-progress-ring" => [ "`stroke_align` — Android, web, Windows and Linux only; iOS and macOS draw an activity indicator" ],
    "control-range-slider" => [ "`label`, `round`, `inactive_color` and `overlay_color` apply on Android, web, Windows and Linux only" ],
    "control-cupertino-date-picker" => [ "Open it with `page.show_dialog(picker)`", "With 0.0.23 a picker added to the page shows nothing" ]
  }.freeze

  test "lines a review fixed keep their next-release state" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    PINNED_NEXT_RELEASE_LINES.each do |slug, kind, name, note|
      line = generated_line(slug, kind, name)

      assert_includes line, "#{note} #{marker}.", "#{slug} #{kind} #{name} lost its next-release note"
    end
    PINNED_RELEASED_LINES.each do |slug, kind, name|
      refute_includes generated_line(slug, kind, name), marker, "#{slug} #{kind} #{name} is not a next-release line"
    end
    assert_includes generated_line("control-context-menu", "methods", "open"), "On iOS and macOS the menu cannot be opened from code"
  end

  test "hand-written sentences about main-only behavior carry the marker" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    PINNED_PROSE_MARKERS.each do |slug, phrases|
      phrases.each do |phrase|
        paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase) }

        assert paragraph, "#{slug} no longer says #{phrase.inspect}"
        assert_includes paragraph, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
  end

  test "hand-written platform qualifications a review added stay on their pages" do
    PINNED_PROSE_QUALIFIERS.each do |slug, phrases|
      phrases.each do |phrase|
        assert prose_chunks(slug).any? { |chunk| chunk.include?(phrase) }, "#{slug} no longer says #{phrase.inspect}"
      end
    end
  end

  # Controls whose every property and event line has its own description in
  # config/property_descriptions.json (a widget override or a shared entry),
  # never the generated "Sets the X property." or "Fired on X.", and whose
  # every method has a method note. The list may only grow.
  FULLY_DESCRIBED_CONTROLS = %w[
    control-about-dialog control-absorb-pointer control-action-sheet control-action-sheet-action
    control-alert-dialog control-animated-switcher control-badge control-banner control-bottom-sheet
    control-card control-carousel-view control-circle-avatar control-clip-oval
    control-clip-r-superellipse control-column control-container control-cupertino-action-sheet
    control-cupertino-action-sheet-action control-cupertino-activity-indicator
    control-cupertino-alert-dialog control-cupertino-bottom-sheet control-cupertino-list-tile
    control-custom-scroll-view control-data-cell control-data-column control-data-column-2
    control-data-row control-data-row-2 control-data-table control-data-table-2 control-dismissible
    control-divider control-drag-target control-draggable control-draggable-scrollable-sheet
    control-expansion-panel control-expansion-panel-list control-expansion-tile
    control-fade-transition control-fitted-box control-fractionally-sized-box
    control-gesture-detector control-grid-view control-hero control-icon control-ignore-pointer
    control-image control-indexed-stack control-interactive-viewer control-intrinsic-height
    control-intrinsic-width control-keyboard-listener control-list-section control-list-tile
    control-list-view control-markdown control-merge-semantics control-nested-scroll-view
    control-overlay control-page-view control-placeholder control-progress-bar control-progress-ring
    control-reorderable-drag-handle control-reorderable-list-view control-responsive-row
    control-rotated-box control-rotation-transition control-row control-ruflet-app control-safe-area
    control-scale-transition control-screenshot control-selection-area control-semantics
    control-shader-mask control-shimmer control-size-transition control-slide-transition
    control-sliver-app-bar control-sliver-fill-remaining control-sliver-grid control-sliver-list
    control-sliver-padding control-sliver-to-box-adapter control-snack-bar control-snack-bar-action
    control-spinkit control-stack control-table control-table-row control-text control-text-span
    control-transparent-pointer control-vertical-divider control-window-drag-area
  ].freeze

  # Two merged branches once each assigned FULLY_DESCRIBED_CONTROLS. Ruby only
  # warns and keeps the second list, so the tests above silently checked fewer
  # controls.
  test "each list in this test is assigned once" do
    names = File.read(__FILE__).scan(/^\s*([A-Z][A-Z0-9_]*)\s*=(?!=)/).flatten
    twice = names.tally.select { |_name, count| count > 1 }.keys

    assert_empty twice, "Merge these constants of #{File.basename(__FILE__)} into one list each: #{twice.join(', ')}"
  end

  test "fully described controls describe every property and event" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    catalog = DocsCatalog.control_catalog.index_by { |control| control[:slug] }

    missing = FULLY_DESCRIBED_CONTROLS.flat_map do |slug|
      control = catalog[slug]
      next [ "#{slug}: not in the catalog" ] unless control

      %w[properties events].flat_map do |kind|
        Array(control[kind.to_sym]).map(&:to_s).reject do |name|
          descriptions.dig("widget_overrides", control[:widget_type].to_s, name) || descriptions.dig(kind, name)
        end.map { |name| "#{slug} #{kind} #{name}" }
      end
    end

    assert_empty missing, "Describe these in config/property_descriptions.json (\"properties\", \"events\" or \"widget_overrides\"):\n#{missing.join("\n")}"
  end

  # Ruflet's server turns the keys of an event's hash payload into symbols, so
  # `event.data["ci"]` is always nil and `event.data[:ci]` is right. These pages
  # still read string keys; fix them, then remove them here.
  STRING_KEY_PAYLOAD_PAGES = %w[control-qrcode-scanner qrcode-scanner].freeze

  test "pages read hash event payloads with symbol keys" do
    offenders = DocsCatalog.all_entries.filter_map do |entry|
      text = entry.content || (entry.source&.exist? ? entry.source.read : "")
      entry.slug if text.match?(/\bevent\.data\[["']/)
    end

    assert_empty offenders - STRING_KEY_PAYLOAD_PAGES, "Read hash payloads with symbol keys, for example `event.data[:ci]`: #{(offenders - STRING_KEY_PAYLOAD_PAGES).join(', ')}"
  end

  # Both clients match a theme or palette color name against
  # /^([a-zA-Z]+)([0-9]*)$/ (colors.dart), so `:surface_container_low` or
  # `:blue_600` draws no color at all. These pages must spell them
  # `:surfacecontainerlow` and `:blue600`.
  test "examples on fully described pages and layout guides spell color names without underscores" do
    offenders = (FULLY_DESCRIBED_CONTROLS + LAYOUT_GUIDES).flat_map do |slug|
      page_text(slug).scan(/\b\w*color: *(?::|")[a-z]+_[a-z0-9_]*/).map { |hit| "#{slug}: #{hit}" }
    end

    assert_empty offenders, "Write color names without underscores, for example `:surfacecontainerlow`:\n#{offenders.join("\n")}"
  end

# Example fixes a review made, which compile either way.
test "examples a review fixed keep their fix" do
  expansion = page("control-expansion-tile").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]
  sheet = page("control-bottom-sheet").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]

  assert_includes expansion, "page.update(event.control, expanded: expanded)", "iOS and macOS redraw an ExpansionTile only when Ruby sets `expanded`"
  assert_includes sheet, "page.close_bottom_sheet(sheet)"
  refute_includes sheet, "copy_link", "The BottomSheet example must run as written"
end

  test "the curated Cupertino date picker example opens the picker as a dialog" do
    example = page("control-cupertino-date-picker").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]

    assert_includes example, "page.show_dialog(picker)", "With 0.0.23 a cupertino_date_picker added to the page shows nothing"
  end

  test "generated examples leave out lines 0.0.23 rejects or ignores everywhere" do
    example = page("control-menu-item-button").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]

    assert example, "control-menu-item-button has no generated example"
    refute_includes example, "trailing:", "MenuItemButton `trailing` is ignored by the 0.0.23 client"
    assert_includes page("control-cupertino-app-bar").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1], "trailing:"
  end

  # Buttons, menus, app bars, navigation, tabs, view and stepper: every
  # property and event line has a written description (a widget override or a
  # shared one), never the "Sets the X property." fallback or a description
  # guessed from the name. Layout keys shared by most controls are listed once
  # on each page and documented elsewhere.
  BUTTON_MENU_NAVIGATION_CONTROLS = %w[
    app-bar bottom-app-bar button context-menu context-menu-action cupertino-app-bar cupertino-button
    cupertino-context-menu cupertino-context-menu-action cupertino-dialog-action cupertino-filled-button
    cupertino-navigation-bar cupertino-tinted-button filled-button filled-icon-button filled-tonal-button
    filled-tonal-icon-button floating-action-button icon-button menu-bar menu-item-button navigation-bar
    navigation-bar-destination navigation-drawer navigation-drawer-destination navigation-rail
    navigation-rail-destination outlined-button outlined-icon-button popup-menu-button popup-menu-item step
    stepper submenu-button tab tab-bar tab-bar-view tabs text-button view
  ].map { |name| "control-#{name}" }.freeze

  # Keys every control shares whose description belongs to other pages.
  SHARED_UNOWNED_KEYS = %w[adaptive on_animation_end on_size_change on_action_result action].freeze

  test "button, menu and navigation controls describe every property and event" do
    descriptions = DocsCatalog.send(:attribute_descriptions)
    common = DocsCatalog.send(:common_properties)
    undescribed = BUTTON_MENU_NAVIGATION_CONTROLS.flat_map do |slug|
      control = DocsCatalog.control_catalog.find { |entry| entry[:slug] == slug }
      assert control, "#{slug} is not in the catalog"
      %w[properties events].flat_map do |kind|
        names = Array(control[kind.to_sym]).map(&:to_s) - common - SHARED_UNOWNED_KEYS
        names.reject do |name|
          descriptions.dig("widget_overrides", control[:widget_type].to_s, name) || descriptions.dig(kind, name)
        end.map { |name| "#{slug} #{kind} #{name}" }
      end
    end

    assert_empty undescribed, "Describe these in config/property_descriptions.json:\n#{undescribed.join("\n")}"
  end

  # Lines that state a platform limit a review checked against both renderers:
  # [slug, kind, name, words the line must keep].
  PINNED_PLATFORM_LINES = [
    [ "control-button", "properties", "border_radius", "Android, web, Windows and Linux ignore it" ],
    [ "control-filled-button", "properties", "opacity_on_click", "Android, web, Windows and Linux ignore it" ],
    [ "control-cupertino-button", "properties", "alignment", "pass `{ x: 0, y: 0 }`" ],
    [ "control-filled-icon-button", "properties", "padding", "pass `padding: 8`" ],
    [ "control-icon-button", "properties", "bgcolor", "Android, web, Windows and Linux ignore it" ],
    [ "control-floating-action-button", "properties", "shape", "Android, web, Windows and Linux only" ],
    [ "control-app-bar", "properties", "center_title", "Android, web, Windows and Linux only" ],
    [ "control-app-bar", "properties", "previous_page_title", "Android, web, Windows and Linux ignore it" ],
    [ "control-context-menu", "properties", "tertiary_trigger", "Android, web, Windows and Linux only" ],
    [ "control-context-menu", "properties", "secondary_trigger",
      "On iOS and macOS only `\"disabled\"` matters: the long press then shows `primary_items` (or `items`) instead of `secondary_items`." ],
    [ "control-context-menu", "events", "on_select", "symbol keys" ],
    [ "control-popup-menu-button", "events", "on_select", "Fired when the user picks an item, after the item's own `on_click`." ],
    # CupertinoSlidingSegmentedControl calls onValueChanged only when the
    # segment changes; the Material TabBar calls onTap for every tap.
    [ "control-tab-bar", "events", "on_click",
      "On Android, web, Windows and Linux it fires for every tap, even on the selected tab; on iOS and macOS only when the selection moves to another tab." ],
    [ "control-menu-item-button", "properties", "disabled", "Draws the entry dimmed and ignores taps (default `false`)." ],
    [ "control-navigation-bar", "properties", "active_color", "Android, web, Windows and Linux ignore it" ],
    [ "control-navigation-rail", "properties", "extended", "Android, web, Windows and Linux only" ],
    [ "control-tab-bar", "properties", "indicator_size", "Android, web, Windows and Linux only" ],
    [ "control-view", "events", "on_scroll", "symbol keys" ],
    [ "control-app-bar", "properties", "automatically_imply_leading", "On Android, web, Windows and Linux it shows a menu button instead" ],
    [ "control-cupertino-app-bar", "properties", "automatically_imply_leading", "iOS and macOS have no menu button" ],
    [ "control-app-bar", "properties", "leading", "a menu button for the `drawer` on Android, web, Windows and Linux" ],
    [ "control-cupertino-app-bar", "properties", "leading", "a menu button for the `drawer` on Android, web, Windows and Linux" ],
    [ "control-navigation-drawer", "events", "on_dismiss", "Picking a destination does not close it." ],
    [ "control-view", "properties", "drawer", "call `page.invoke` with this view and `\"show_drawer\"`" ],
    [ "control-view", "properties", "end_drawer", "call `page.invoke` with this view and `\"show_end_drawer\"`" ]
  ].freeze

  test "button, menu and navigation lines keep their platform limits" do
    PINNED_PLATFORM_LINES.each do |slug, kind, name, words|
      assert_includes generated_line(slug, kind, name), words, "#{slug} #{kind} #{name} lost #{words.inspect}"
    end
    assert_includes generated_line("control-context-menu", "properties", "items"),
      "On Android, web, Windows and Linux, the 0.0.23 client shows them only from `open`; a click shows the trigger's own list or `actions`. #{DocsCatalog::NEXT_RELEASE_MARKER}."
    assert_includes generated_line("control-outlined-button", "events", "on_hover"),
      "On Android, web, Windows and Linux, the 0.0.23 client never sends it for a button with an `icon`. #{DocsCatalog::NEXT_RELEASE_MARKER}.",
      "With 0.0.23 the Material OutlinedButton.icon has no onHover"
    refute_includes generated_line("control-popup-menu-button", "events", "on_select"), "before the item's own"
    # The iOS sheet ignores close_on_click: on main a pick always closes it,
    # and with 0.0.23 a pick of an entry with on_click leaves it open.
    assert_equal "- `close_on_click` — Closes the menu when the entry is clicked (default `true`). Android, web, Windows and Linux only.",
      generated_line("control-menu-item-button", "properties", "close_on_click").chomp
    # Shared by sliver_app_bar, which on iOS and macOS draws a Cupertino bar.
    assert_equal "Adds a back button when the page can go back. On Android, web, Windows and Linux it adds a menu button instead when the page has a drawer.",
      DocsCatalog.send(:attribute_descriptions).dig("properties", "automatically_imply_leading")
    assert prose_chunks("control-app-bar").any? { |chunk|
      chunk.include?("adds a back button when `automatically_imply_leading` (default `true`) allows, or, on Android, web, Windows and Linux, a menu button when the page has a `drawer`")
    }, "control-app-bar: iOS and macOS have no menu button"
  end

  # A `false` event payload reaches the handler as `nil` (ruflet_server's
  # Protocol.normalize_control_event_payload; event_data_docs_test.rb checks
  # it against the Ruflet source), so a line that describes it says so.
  test "button, menu and navigation lines say a false payload arrives as nil" do
    lines = BUTTON_MENU_NAVIGATION_CONTROLS.flat_map do |slug|
      generated_api_lines(page(slug).content).filter_map { |kind, name, line| [ slug, name, line ] if kind == "events" && name.in?(%w[on_hover on_click]) }
    end
    leaving = lines.select { |_slug, name, line| name == "on_hover" && line.include?("off it") }

    assert_equal 11, leaving.size, leaving.map(&:first).join(", ")
    leaving.each do |slug, _name, line|
      assert_includes line, "and off it (the client sends `false`, which arrives in Ruby as `nil`)", slug
    end
    lines.each { |slug, name, line| refute_match(/`event\.data` is `false`/, line, "#{slug} #{name}") }
    assert_includes generated_line("control-popup-menu-item", "events", "on_click"),
      "when it was checked the client sends `false`, which arrives in Ruby as `nil`"
    assert_includes generated_line("control-context-menu-action", "events", "on_click"),
      "one that becomes unchecked sends `false`, which arrives in Ruby as `nil`"
    assert prose_chunks("control-popup-menu-item").any? { |chunk|
      chunk.include?("keep the state yourself and update `checked` in `on_click`: `event.data` is `true` or `nil`, never `false`.")
    }, "control-popup-menu-item: the summary says a false click payload arrives as nil"
    # Only a top-level `false` becomes `nil`: a Hash payload is kept, `false`
    # values and all (event_data_docs_test.rb checks this too).
    assert_includes generated_line("control-tab-bar", "events", "on_hover"),
      "`event.data` is a hash with symbol keys: `:hovering` (`true` or `false`) and `:index`."
    # The shared line is what container, gesture_detector and map show, and
    # their pages do not all describe on_hover's data.
    assert_equal "Fired when a mouse pointer moves onto or off the control; touch input never fires it.",
      DocsCatalog.send(:attribute_descriptions).dig("events", "on_hover")
  end

  # What the 0.0.23 client (template main) does on iOS and macOS where the
  # engine default branch now differs, each checked with a widget test of
  # both renderers: [slug, kind, name, words the line must keep].
  PINNED_CUPERTINO_0023_LINES = [
    # ruflet-engine#125: the iOS tab bar drops a tap on a disabled destination;
    # the 0.0.23 cupertino_navigation_bar.dart _onTap selects it.
    [ "control-navigation-bar-destination", "properties", "disabled",
      "On iOS and macOS, the 0.0.23 client still selects it when tapped and sends the bar's `on_change`. #{DocsCatalog::NEXT_RELEASE_MARKER}." ],
    [ "control-navigation-bar-destination", "properties", "disabled", "is drawn dimmed and ignores taps" ],
    [ "control-navigation-bar-destination", "properties", "tooltip", "The iOS tab bar on iOS and macOS shows no tooltips." ],
    # With 0.0.23 a Cupertino menu entry wins the tap, so the sheet's own row
    # handler, which sends `select` and closes the sheet, never runs.
    [ "control-popup-menu-button", "events", "on_select",
      "On iOS and macOS, the 0.0.23 client never sends it. #{DocsCatalog::NEXT_RELEASE_MARKER}." ],
    [ "control-submenu-button", "events", "on_close",
      "On iOS and macOS, the 0.0.23 client leaves the sheet open when the user picks an entry that has `on_click`, so it fires only once the user taps outside the sheet; " \
      "a tap on an entry without `on_click`, or on a disabled one, closes the sheet and fires it. #{DocsCatalog::NEXT_RELEASE_MARKER}." ],
    # With 0.0.23 the sheet's row handler ignores `disabled` and sends `click`;
    # on main a disabled row has no onTap.
    [ "control-menu-item-button", "properties", "disabled",
      "On iOS and macOS, the 0.0.23 client still sends `on_click` when the user taps a disabled entry in a submenu's sheet, and closes the sheet. #{DocsCatalog::NEXT_RELEASE_MARKER}." ],
    # With 0.0.23 a popup item on iOS and macOS is a CupertinoContextMenuAction,
    # which sends `click` without data; on main the sheet row sends !checked.
    [ "control-popup-menu-item", "events", "on_click",
      "On iOS and macOS, the 0.0.23 client sends no data, so `event.data` is always `nil` there. #{DocsCatalog::NEXT_RELEASE_MARKER}." ],
    # The 0.0.23 cupertino_context_menu.dart reads no trigger.
    [ "control-context-menu", "properties", "secondary_trigger",
      "On iOS and macOS, the 0.0.23 client ignores it. #{DocsCatalog::NEXT_RELEASE_MARKER}." ]
  ].freeze

  test "button, menu and navigation lines say what the 0.0.23 client does on iOS and macOS" do
    PINNED_CUPERTINO_0023_LINES.each do |slug, kind, name, words|
      assert_includes generated_line(slug, kind, name), words, "#{slug} #{kind} #{name} lost #{words.inspect}"
    end
    refute_includes generated_line("control-menu-item-button", "properties", "close_on_click"), "always closes the sheet",
      "with 0.0.23 a pick leaves the iOS sheet open"
    {
      "control-navigation-bar" => "with 0.0.23 a tap still selects it and sends `on_change`",
      "control-popup-menu-button" => "with 0.0.23 it sends neither there",
      "control-menu-bar" => "With 0.0.23 the sheet stays open after the user picks an entry that has `on_click`, until the user taps outside it, " \
        "and a tap on a disabled entry still runs its `on_click` and closes the sheet."
    }.each do |slug, phrase|
      paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase) }

      assert paragraph, "#{slug} no longer says #{phrase.inspect}"
      assert_includes paragraph, DocsCatalog::NEXT_RELEASE_MARKER, "#{slug}: #{phrase.inspect} needs the next-release marker"
    end
    # What main does, ahead of the 0.0.23 sentence in the same paragraph.
    assert prose_chunks("control-menu-bar").any? { |chunk|
      chunk.include?("On iOS and macOS, picking an entry also closes the sheet and fires the submenu's `on_close`, and a disabled entry ignores taps. With 0.0.23")
    }, "control-menu-bar: on main a disabled entry in the iOS sheet ignores taps"
    # The popup_menu_item summary (config/control_docs.json) marks the 0.0.23
    # iOS menu, like its on_click line.
    assert prose_chunks("control-popup-menu-item").any? { |chunk|
      chunk.include?("With 0.0.23 the iOS and macOS menu sends no data, so `event.data` is always `nil` there. #{DocsCatalog::NEXT_RELEASE_MARKER}.")
    }, "control-popup-menu-item: the summary lost the marked 0.0.23 iOS sentence"
  end

  # A hand-written paragraph about iOS and macOS that names a line the 0.0.23
  # Cupertino client lacks (config/next_release.json "design_client_ignored"
  # "cupertino") describes main-only behavior, so it carries the marker.
  test "button, menu and navigation pages mark their iOS paragraphs about main-only lines" do
    cupertino = DocsCatalog.next_release[:design_client_ignored].fetch("cupertino")
    unmarked = BUTTON_MENU_NAVIGATION_CONTROLS.flat_map do |slug|
      next [] unless DocsCatalog::SOURCE_ROOT.join("#{slug.tr('-', '_')}.md").exist?

      names = cupertino.fetch(slug, {}).values.flat_map { |list| list.is_a?(Hash) ? list.keys : list }
      prose = page(slug).content.split("\n## Complete API\n", 2).first.gsub(/^```.*?^```/m, "")
      prose.split(/\n(?=- |\n)/).map(&:squish).reject { |chunk| chunk.include?(DocsCatalog::NEXT_RELEASE_MARKER) }.filter_map do |chunk|
        hit = names.find { |name| chunk.include?("`#{name}`") }
        "#{slug} (#{hit}): #{chunk}" if hit && chunk.include?("iOS")
      end
    end

    assert_empty unmarked, "These paragraphs describe what only main does on iOS and macOS:\n#{unmarked.join("\n")}"
  end

  # The Navigation and Feedback guide runs as written: every method its
  # examples call without a receiver is a Ruflet helper, `page`, a Kernel
  # method, or something the page defines (a `def`, or a variable an example
  # assigns and reads, such as the `render_route` lambda), and every method
  # called on `page` is a public Page method (config/runtime_catalog.json).
  test "navigation and feedback examples define every app method they call" do
    content = DocsCatalog::SOURCE_ROOT.join("navigation_feedback.md").read
    nodes = content.scan(/^```ruby\n(.*?)^```/m).flatten.flat_map do |code|
      result = Prism.parse(code)
      assert result.success?, "navigation_feedback.md has a block that does not parse:\n#{code}"
      ruby_nodes(result.value)
    end
    defined = nodes.grep(Prism::DefNode).map(&:name)
    assigned = nodes.grep(Prism::LocalVariableWriteNode).map(&:name)
    helpers = DocsCatalog.control_catalog.flat_map { |control| Array(control[:helpers]) } +
      DocsCatalog.service_catalog.fetch(:services).map { |service| service[:helper] }
    undefined = nodes.grep(Prism::CallNode).select { |call| call.receiver.nil? }.reject do |call|
      helpers.include?(call.name.to_s) || call.name == :page || defined.include?(call.name) ||
        Kernel.private_method_defined?(call.name) || (call.variable_call? && assigned.include?(call.name))
    end

    assert_operator nodes.grep(Prism::CallNode).size, :>, 50
    assert_empty undefined.map(&:slice), "navigation_feedback.md calls these, which no example defines"

    page_methods = JSON.parse(Rails.root.join("config/runtime_catalog.json").read).fetch("page").reject { |method| method["internal"] }.map { |method| method["name"] }
    page_calls = nodes.grep(Prism::CallNode).select do |call|
      receiver = call.receiver
      (receiver.is_a?(Prism::CallNode) && receiver.receiver.nil? && receiver.name == :page) ||
        (receiver.is_a?(Prism::LocalVariableReadNode) && receiver.name == :page)
    end

    assert_operator page_calls.size, :>, 10
    assert_empty page_calls.reject { |call| page_methods.include?(call.name.to_s) }.map(&:slice),
      "navigation_feedback.md calls these on page, which are not public Page methods"
    assert_includes content, "render_route = lambda do"
    %w[control-view control-navigation-bar control-navigation-rail control-navigation-drawer control-tabs
       control-app-bar control-popup-menu-button control-menu-bar control-context-menu].each do |slug|
      assert_includes content, "(/docs/#{slug})", "navigation_feedback.md should link #{slug}"
    end
  end

  # `page.show_drawer` and the other drawer shortcuts send a page method the
  # 0.0.23 client does not know, so a generated line may name them only with
  # the marker. `page.invoke(view, "show_drawer")` works on 0.0.23 and main.
  test "button, menu and navigation lines name the drawer shortcuts only with the marker" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    wrong = BUTTON_MENU_NAVIGATION_CONTROLS.flat_map do |slug|
      generated_api_lines(page(slug).content).filter_map do |kind, name, line|
        "#{slug} #{kind} #{name}" if line.match?(/page\.(show|close)_(end_)?drawer/) && !line.include?(marker)
      end
    end

    assert_empty wrong, "These lines tell 0.0.23 apps to call a drawer method its client rejects:\n#{wrong.join("\n")}"
  end

  # Ways of writing that work on 0.0.23 and that a review found missing.
  test "button, menu and navigation pages keep the forms that work on 0.0.23" do
    %w[control-icon-button control-filled-icon-button control-filled-tonal-icon-button control-outlined-icon-button].each do |slug|
      assert_includes generated_line(slug, "properties", "icon"), "or the symbol `:add`", "#{slug}: symbol icon names work on 0.0.23"
    end
    assert prose_chunks("control-icon-button").any? { |chunk| chunk.include?("or a symbol such as `:add`") },
      "control-icon-button: symbol icon names work on 0.0.23"

    marker = DocsCatalog::NEXT_RELEASE_MARKER
    drawer = page("control-navigation-drawer").content
    invoke_section = drawer[/^### Open and close the drawer from code\n(.*?)(?=^### |\z)/m, 1]

    assert invoke_section, "control-navigation-drawer lost the section that opens a view's drawer"
    refute_includes invoke_section, marker, "page.invoke(view, \"show_drawer\") works on 0.0.23"
    assert_includes invoke_section, "page.invoke(home, \"show_drawer\")"
    assert_includes invoke_section, "page.invoke(home, \"close_drawer\")"
    assert_includes invoke_section, "page.views = [home]"
    assert prose_chunks("control-navigation-drawer").any? { |chunk| chunk.include?("With 0.0.23 that means a view's drawer opened with `page.invoke`") },
      "control-navigation-drawer: on iOS and macOS a 0.0.23 app opens the drawer with page.invoke on a view"
    assert_includes invoke_section.squish, "This works with 0.0.23 and on every platform."
    refute_includes drawer, "cannot be opened at all", "a 0.0.23 app can open a view's drawer with page.invoke"
  end

  test "button, menu and navigation pages keep their next-release and known-issue notes" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    {
      "control-context-menu" => [ "a click skips `items` and shows `actions`", "and fires both events" ],
      "control-navigation-drawer" => [ "With 0.0.23 the client answers these calls with an \"Unknown Page method\" error" ],
      "control-icon-button" => [ "the 0.0.23 client\nignores it", "With 0.0.23 the Material icon button ignores `style:`" ]
    }.each do |slug, phrases|
      phrases.each do |phrase|
        paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase.squish) }

        assert paragraph, "#{slug} no longer says #{phrase.inspect}"
        assert_includes paragraph, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
    %w[control-cupertino-button control-cupertino-filled-button control-cupertino-tinted-button
       control-filled-icon-button control-filled-tonal-icon-button control-outlined-icon-button].each do |slug|
      example = page(slug).content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]

      assert_includes example, "alignment: { x: 0, y: 0 }", "#{slug}: with default arguments the client cannot read the alignment Ruby sends (ruflet#94)"
    end
    # ruflet#94 is a 0.0.23 client bug; the engine default branch reads that alignment.
    summary = DocsCatalog.control_docs.dig("control-cupertino-filled-button", "summary")
    assert_includes summary, "an `alignment` the 0.0.23 client cannot read, so on iOS and macOS it draws an error box instead of the button,"
    refute_includes summary, "everywhere with"
  end

  # Every name a "Common properties" item starts with (the part before " — ")
  # must be a keyword, event or method of the control. `cupertino_button` has
  # no `style:`, for example, so listing it would document an ArgumentError.
  test "button, menu and navigation pages list only real keywords under Common properties" do
    wrong = BUTTON_MENU_NAVIGATION_CONTROLS.flat_map do |slug|
      next [] unless DocsCatalog::SOURCE_ROOT.join("#{slug.tr('-', '_')}.md").exist?

      control = DocsCatalog.control_catalog.find { |entry| entry[:slug] == slug }
      known = %i[properties events methods].flat_map { |kind| Array(control[kind]).map { |entry| entry.is_a?(Hash) ? entry[:name].to_s : entry.to_s } }
      section = page(slug).content[/^## Common properties\n\n(.*?)(?=^## |\z)/m, 1].to_s
      section.scan(/^- (.+)$/).flatten.flat_map do |item|
        item.split(" — ", 2).first.scan(/`([a-z_0-9?]+)`/).flatten.reject { |name| known.include?(name) }.map { |name| "#{slug}: #{name}" }
      end
    end

    assert_empty wrong, "These Common properties names are not keywords of their control:\n#{wrong.join("\n")}"
  end
  test "fully described controls have no generic property, event or method lines" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    catalog = DocsCatalog.control_catalog.index_by { |control| control[:slug] }

    generic = FULLY_DESCRIBED_CONTROLS.flat_map do |slug|
      control = catalog[slug]
      next [ "#{slug} is not in the catalog" ] unless control

      widget = control[:widget_type].to_s
      overrides = descriptions.dig("widget_overrides", widget) || {}
      lines = %w[properties events].flat_map do |kind|
        Array(control[kind.to_sym]).map(&:to_s)
                                   .reject { |name| overrides.key?(name) || descriptions[kind].key?(name) }
                                   .map { |name| "#{slug} #{kind} #{name}" }
      end
      lines + Array(control[:methods]).map { |method| method[:name].to_s }
                                      .reject { |name| descriptions.dig("method_notes", widget, name) }
                                      .map { |name| "#{slug} methods #{name}" }
    end

    assert_empty generic, "Describe these lines in config/property_descriptions.json:\n#{generic.join("\n")}"
  end

  test "shared layout descriptions say what the clients do" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    properties = descriptions.fetch("properties")
    events = descriptions.fetch("events")
    common = DocsCatalog.send(:common_properties)

    assert_empty common - properties.keys - events.keys, "Every key in config/control_common_properties.json needs a shared description"
    assert_includes properties.fetch("adaptive"), "no Ruflet client reads it"
    assert_includes properties.fetch("expand"), "an integer sets the share"
    assert_includes events.fetch("on_size_change"), "`{ w: width, h: height }`"
    assert_includes events.fetch("on_end_reached"), "the keys `:pixels`"
    # end_reached_listener.dart re-arms when the content grows or when the
    # user scrolls back more than twice the threshold from the end.
    assert_includes events.fetch("on_end_reached"), "scrolls back more than twice `end_reached_threshold` from the end"
    %w[opacity rotation scale offset align margin position container].each do |name|
      assert_includes events.fetch("on_animation_end"), "`\"#{name}\"`"
    end
    assert_includes properties.fetch("margin"), "`all:`", "engine #119 reads { all: n } margins on main"
    assert_includes properties.fetch("align"), "`\"top_left\"`", "engine #119 reads named alignments on main"
    assert_includes descriptions.dig("widget_overrides", "container", "padding"), "`all:`"
    assert_includes descriptions.dig("widget_overrides", "container", "border_radius"), "`all:`"
  end

  # A generated line carries the marker only when its key needs the next
  # release (the test above), so a description that names a shape only Ruflet
  # main reads points to the guide section that carries the marker instead.
  # The shapes are the `all:` shorthand and the named alignments of engine
  # #119 (`"center"` alone also works on 0.0.23, as a container alignment).
  # Overrides of controls that only have next-release pages need no link.
  MAIN_ONLY_SHAPES = [
    /Ruflet main/,
    /`(?:\{ *)?all:/,
    /`"(?:top|center|bottom)_?(?:left|center|right)"`/i
  ].freeze

  test "descriptions that name main-only shapes link to the marked guide section" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    next_release_pages = JSON.parse(Rails.root.join("config/next_release.json").read).fetch("controls")
    slugs_by_widget = DocsCatalog.control_catalog.group_by { |control| control[:widget_type].to_s }.transform_values { |controls| controls.map { |control| control[:slug] } }
    texts = %w[properties events].flat_map { |kind| descriptions.fetch(kind).map { |name, text| [ "#{kind}.#{name}", text ] } }
    texts += descriptions.fetch("widget_overrides").flat_map do |widget, names|
      next [] if (slugs_by_widget[widget] || []).then { |slugs| slugs.any? && (slugs - next_release_pages).empty? }

      names.map { |name, text| [ "#{widget}.#{name}", text ] }
    end

    unlinked = texts.select do |_name, text|
      MAIN_ONLY_SHAPES.any? { |shape| text.match?(shape) } &&
        !text.include?("](/docs/controls-and-layout#option-values)") && !text.include?(DocsCatalog::NEXT_RELEASE_MARKER)
    end

    assert_empty unlinked.map(&:first), "Link these to [Option values](/docs/controls-and-layout#option-values), which marks the main-only shapes: #{unlinked.map(&:first).join(', ')}"
    assert_equal [ true, true, true, false ], [
      "`{ all: 16 }`", "such as `\"top_left\"`", "or `\"bottomRight\"`", "`\"center\"` is also accepted"
    ].map { |text| MAIN_ONLY_SHAPES.any? { |shape| text.match?(shape) } }
  end

  # Wording true for one wire type of this group. A shared entry would also
  # render on other controls with the same key (an audio's src_base64, a
  # lottie's animate, a web_view's on_scroll, which sends { x:, y: }).
  LAYOUT_ONLY_DESCRIPTIONS = {
    "container" => %w[animate image shadow],
    "image" => %w[src_base64 error_content],
    "markdown" => %w[code_theme]
  }.freeze
  SCROLL_EVENT_WIDGETS = %w[column row listview gridview customscrollview nestedscrollview reorderablelistview responsiverow].freeze

  test "wording for one layout control stays in its widget override" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    overrides = descriptions.fetch("widget_overrides")

    LAYOUT_ONLY_DESCRIPTIONS.each do |widget, names|
      names.each do |name|
        assert overrides.dig(widget, name), "widget_overrides.#{widget} needs #{name}"
        assert_nil descriptions.fetch("properties")[name], "A shared #{name} description also renders on other controls; keep it in widget_overrides.#{widget}"
      end
    end
    SCROLL_EVENT_WIDGETS.each do |widget|
      assert_includes overrides.dig(widget, "on_scroll").to_s, "`:event_type`", "widget_overrides.#{widget} needs the on_scroll payload"
    end
    refute_includes descriptions.fetch("events").fetch("on_scroll"), "event.data", "web_view also uses the shared on_scroll text, and its payload is { x:, y: }"
  end

  # The layout, scrolling, sliver, transition, gesture and accessibility
  # pages, and their guide.
  LAYOUT_GUIDES = %w[controls-and-layout].freeze
  LAYOUT_PAGES = (%w[
    control-absorb-pointer control-animated-switcher control-badge control-card control-carousel-view
    control-circle-avatar control-clip-oval control-clip-r-superellipse control-column control-container
    control-custom-scroll-view control-dismissible control-divider control-drag-target control-draggable
    control-draggable-scrollable-sheet control-fade-transition control-fitted-box
    control-fractionally-sized-box control-gesture-detector control-grid-view control-hero control-icon
    control-ignore-pointer control-image control-indexed-stack control-interactive-viewer
    control-intrinsic-height control-intrinsic-width control-keyboard-listener control-list-view
    control-markdown control-merge-semantics control-nested-scroll-view control-overlay control-page-view
    control-placeholder control-reorderable-drag-handle control-reorderable-list-view control-responsive-row
    control-rotated-box control-rotation-transition control-row control-ruflet-app control-safe-area
    control-scale-transition control-screenshot control-selection-area control-semantics control-shader-mask
    control-shimmer control-size-transition control-slide-transition control-sliver-app-bar
    control-sliver-fill-remaining control-sliver-grid control-sliver-list control-sliver-padding
    control-sliver-to-box-adapter control-stack control-text control-text-span control-transparent-pointer
    control-vertical-divider control-window-drag-area
  ] + LAYOUT_GUIDES).freeze

  # Hand-written sentences of the layout pages that describe main-only
  # behavior (each must carry the marker) or one design only (each must stay).
  # Together with the callouts below, these are the only places a layout page
  # may carry the marker: add a phrase only after its example fails on 0.0.23.
  LAYOUT_PROSE_MARKERS = {
    "controls-and-layout" => [
      "Snake case, such as `\"space_between\"`, also works on Ruflet main",
      "On Ruflet main these alignments also take a name",
      "On Ruflet main such a hash can also give `all:`",
      "lays out its children like a `column`, so `expand` works inside it too",
      "`text_field(text_input_action:)` — the keyboard's action key",
      "`text_field(on_paste_files:)` — the user pasted files into the field",
      "`list_tile(chevron: true)` — draws a trailing chevron",
      "`list_tile(focus_color:)` — the Material keyboard-focus highlight",
      "`search_bar(on_tap_outside_view:)` — the user tapped outside the open search view",
      "`semantics(identifier:)` — a stable ID for accessibility tools and UI tests",
      "`app_bar(large: true)` — the Material 3 large app bar",
      "This example uses several of them."
    ],
    "control-row" => [ "`on_end_reached`, `end_reached_threshold` and `keyboard_dismiss_behavior` work on a scrolling row too" ],
    "control-container" => [
      "`opacity_on_click` — the opacity an `ink: true` container fades to",
      "On Ruflet main `alignment` also takes other names",
      "On Ruflet main those hashes can also give `all:`"
    ],
    "control-dismissible" => [ "`movement_duration` / `resize_duration` — slide and close times" ],
    "control-image" => [ "`src_base64:` is the same data under its own name" ],
    "control-page-view" => [ "`next_page`, `previous_page`, `jump_to_page` and `go_to_page` methods" ],
    "control-reorderable-list-view" => [ "`spacing` — space between items; the 0.0.23 client ignores it", "`auto_scroll_animation` and `keyboard_dismiss_behavior`" ],
    "control-semantics" => [ "Drawing the wrapped `content` needs the next release" ],
    "control-screenshot" => [ "An Integer `pixel_ratio:` needs the next release" ]
  }.freeze

  LAYOUT_PROSE_QUALIFIERS = {
    "controls-and-layout" => [
      "`cupertino_switch` sends the same `Switch` control as `switch`",
      "No Ruflet client reads it, and the design follows the platform with or without it."
    ],
    "control-text" => [ "on Android, web, Windows and Linux it fires only for `selectable: true` text" ],
    "control-badge" => [ "iOS and macOS need a label" ],
    "control-card" => [ "draw the `shape` border over the content (default `true`); Android, web, Windows and Linux only" ],
    "control-container" => [ "On leave the client sends `false`, which arrives in Ruby as `nil`" ],
    "control-reorderable-list-view" => [ "`semantic_child_count` is accepted, but no Ruflet client reads it" ]
  }.freeze

  # Sections of hand-written layout pages that need the next release: each
  # heading must be followed directly by the callout.
  LAYOUT_SECTION_CALLOUTS = {
    "control-column" => [ "Refreshing and loading more" ],
    "control-list-view" => [ "Refreshing and loading more" ],
    "control-grid-view" => [ "Refreshing and loading more" ],
    "control-semantics" => [ "Example" ],
    "controls-and-layout" => [ "Scrolling", "Transitions, clips and sizing boxes", "Control methods" ]
  }.freeze

  test "main-only sections of layout pages open with the callout" do
    callout = "> #{DocsCatalog::NEXT_RELEASE_MARKER}."

    LAYOUT_SECTION_CALLOUTS.each do |slug, headings|
      headings.each do |heading|
        section = page_text(slug)[/^## #{Regexp.escape(heading)}\n\n(.*?)(?=^## |\z)/m, 1]

        assert section, "#{slug} has no ## #{heading} section"
        assert section.start_with?(callout), "#{slug}: ## #{heading} needs the next-release callout right under the heading"
      end
    end

    example = page("control-semantics").content[/^## Example\n\n(.*?)^```ruby/m, 1]
    assert_includes example.to_s, callout, "The 0.0.23 client draws nothing for semantics, so its example needs the callout"
  end

  # The other direction: a marker on a layout page sits only in the callout
  # under the H1 of a config/next_release.json page, in a callout under a
  # LAYOUT_SECTION_CALLOUTS heading, or in a LAYOUT_PROSE_MARKERS sentence, so
  # a sentence that works on 0.0.23 cannot gain one unnoticed. Generated
  # property, event and method lines follow config/next_release.json instead.
  test "layout pages carry the marker only where it is pinned" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    next_release_pages = JSON.parse(Rails.root.join("config/next_release.json").read).fetch("controls")

    unexpected = LAYOUT_PAGES.flat_map do |slug|
      hand_written(page_text(slug)).split(/^(?=## )/).flat_map do |section|
        heading = section[/\A## (.+)$/, 1]
        chunks = section.split(/\n(?=- |\n)/).map(&:squish).select { |chunk| chunk.include?(marker) }
        chunks.each_with_index.reject do |chunk, index|
          if chunk.start_with?("> #{marker}")
            heading ? index.zero? && Array(LAYOUT_SECTION_CALLOUTS[slug]).include?(heading) : next_release_pages.include?(slug)
          else
            Array(LAYOUT_PROSE_MARKERS[slug]).any? { |phrase| chunk.include?(phrase) }
          end
        end.map { |chunk, _index| "#{slug} (#{heading || 'intro'}): #{chunk.truncate(120)}" }
      end
    end

    assert_operator LAYOUT_PAGES.size, :>, 60
    assert_empty unexpected, "Only main-only behavior gets the next-release marker. Remove it, or pin the sentence in LAYOUT_PROSE_MARKERS after checking that it fails on 0.0.23:\n#{unexpected.join("\n")}"
  end

  # Descriptions point to /docs/controls-and-layout#option-values instead of
  # carrying the marker, so a renamed heading would leave them pointing
  # nowhere. Every /docs link of every page must reach a page and a heading.
  test "docs links reach an existing page and heading" do
    entries = DocsCatalog.all_entries.index_by(&:slug)
    heading_ids = Hash.new { |ids, slug| ids[slug] = MarkdownRenderer.render(entry_text(entries.fetch(slug))).headings.map(&:id) }

    links = entries.values.flat_map do |entry|
      entry_text(entry).gsub(/^```.*?^```$/m, "").scan(%r{\]\(/docs/([a-z0-9-]+)(?:#([a-z0-9-]+))?\)}).map { |slug, anchor| [ entry.slug, slug, anchor ] }
    end
    broken = links.uniq.filter_map do |from, slug, anchor|
      next "#{from}: /docs/#{slug} is not a page" unless entries.key?(slug)
      next unless anchor

      "#{from}: /docs/#{slug}##{anchor} is not a heading" unless heading_ids[slug].include?(anchor)
    end

    assert_operator links.count { |_from, slug, anchor| slug == "controls-and-layout" && anchor == "option-values" }, :>, 100
    assert_empty broken, broken.join("\n")
  end

  test "layout descriptions a review fixed keep their fix" do
    overrides = JSON.parse(Rails.root.join("config/property_descriptions.json").read).fetch("widget_overrides")

    assert_includes overrides.dig("container", "on_hover"), "arrives in Ruby as `nil`", "a container's on_hover leave payload false reaches Ruby as nil"
    # drag_target.dart sends the Set literal {"src_id", id}, which arrives as a
    # two-item list, so DragTargetEvent finds no src_id. When the engine sends
    # a map instead (AdamMusa/ruflet-engine#127), change this line with it.
    assert_includes overrides.dig("dragtarget", "on_leave"), "`event.data[1]`"
    assert_includes overrides.dig("dragtarget", "on_leave"), "`event.src_id` is nil here"
    assert_includes overrides.dig("windowdragarea", "on_drag_start"), "`:l` is the point in the area"
    assert_includes overrides.dig("windowdragarea", "on_drag_end"), "`:v` is the velocity"
  end

  test "layout pages read event payloads with symbol keys and decorate text with constants" do
    slugs = FULLY_DESCRIBED_CONTROLS + %w[controls-and-layout]
    string_keys = slugs.select { |slug| page_text(slug).match?(/\bevent\.data(?:\[:\w+\])*\[["']/) }
    string_key_names = slugs.flat_map { |slug| string_payload_keys(page_text(slug)).map { |key| "#{slug}: #{key}" } }
    texts = DocsCatalog.all_entries.to_h { |entry| [ entry.slug, entry_text(entry) ] }
    string_decorations = texts.select { |_slug, text| text.match?(/\bdecoration: ["']/) }.keys
    symbol_decorations = texts.select { |_slug, text| text.match?(/\bdecoration: :(?!:)/) }.keys

    assert_empty string_keys, "The server gives event.data hashes Symbol keys, so read event.data[:key]: #{string_keys.join(', ')}"
    assert_empty string_key_names, "The server gives event.data hashes Symbol keys, so name them as `:key`:\n#{string_key_names.join("\n")}"
    assert_empty string_decorations, "Clients read decoration as a Ruflet::TextDecoration bit mask; a String draws nothing: #{string_decorations.join(', ')}"
    assert_empty symbol_decorations, "A Symbol decoration reaches the client as a String and draws nothing; use Ruflet::TextDecoration: #{symbol_decorations.join(', ')}"
  end

  test "the payload key check finds String keys in prose" do
    flagged = [
      "- `on_end_reached` — `event.data` has the keys `\"pixels\"` and `:viewport_dimension`.",
      "- `on_extent_change` — `event.data` has `\"extent\"`, `:min` and `:max`.",
      "`event.data` has the keys `:selection`, a hash with `\"base_offset\"` and `:extent_offset`.",
      "`event.data` is `{ \"w\" => width, \"h\" => height }`.",
      "Read the position from `event.data`:\n\n- `\"event_type\"` — `\"start\"` or `\"end\"`\n- `:pixels` — the offset; `\"max_scroll_extent\"` bounds it"
    ]
    kept = [
      "`event.data` is a hash with the keys `:event_type` (`\"start\"` or `\"end\"`), `:pixels` and `:velocity`.",
      "Read the position from `event.data`:\n\n- `:event_type` — `\"start\"` or `\"end\"`\n- `:direction` (`\"idle\"` or `\"forward\"`) on user events",
      "`event.data` names the animation: `\"opacity\"` or `\"scale\"`.",
      "- `col` — a hash per breakpoint such as `{ \"xs\" => 12, \"md\" => 6 }`."
    ]

    assert_equal [ 1, 1, 1, 1, 2 ], flagged.map { |text| string_payload_keys(text).size }
    assert_equal [ 0, 0, 0, 0 ], kept.map { |text| string_payload_keys(text).size }
  end

  test "layout pages keep their next-release markers and platform notes" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    # Guides such as controls-and-layout render from their source file.
    chunks = lambda do |slug|
      entry = page(slug)
      next prose_chunks(slug) if entry.content

      entry.source.read.split(/\n(?=- |\n)/).map(&:squish)
    end

    LAYOUT_PROSE_MARKERS.each do |slug, phrases|
      phrases.each do |phrase|
        chunk = chunks.call(slug).find { |candidate| candidate.include?(phrase) }

        assert chunk, "#{slug} no longer says #{phrase.inspect}"
        assert_includes chunk, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
    LAYOUT_PROSE_QUALIFIERS.each do |slug, phrases|
      phrases.each do |phrase|
        assert chunks.call(slug).any? { |chunk| chunk.include?(phrase) }, "#{slug} no longer says #{phrase.inspect}"
      end
    end
  end

  private

  # The hand-written part of a page (everything above a prose page's Complete
  # API appendix), split into paragraphs and list items, each on one line.
  def prose_chunks(slug)
    page(slug).content.split("\n## Complete API\n", 2).first.split(/\n(?=- |\n)/).map(&:squish)
  end

  # A Prism node and every node under it.
  def ruby_nodes(node)
    [ node ] + node.compact_child_nodes.flat_map { |child| ruby_nodes(child) }
  end

  # The one generated "- `name` ..." line of a kind on a control page.
  def generated_line(slug, kind, name)
    lines = generated_api_lines(page(slug).content).select { |line_kind, line_name, _line| line_kind == kind && line_name == name }

    assert_equal 1, lines.size, "#{slug} should render one #{kind} line for #{name}"
    lines.first.last
  end

  # [list, slug, kind, name] for every line config/next_release.json marks:
  # "members", "client_ignored" and each design of "design_client_ignored",
  # whose names are an array or a hash of name => note.
  def next_release_lists(config)
    lists = %w[members client_ignored].map { |list| [ list, config.fetch(list) ] }
    config.fetch("design_client_ignored").each { |design, controls| lists << [ "design_client_ignored #{design}", controls ] }
    lists.flat_map do |list, controls|
      controls.flat_map do |slug, kinds|
        kinds.flat_map { |kind, names| (names.is_a?(Hash) ? names.keys : names).map { |name| [ list, slug, kind, name ] } }
      end
    end
  end

  # [kind, name, line] for each generated "- `name` — ..." or "- `name(...)`"
  # line: the Properties, Events and Methods lists of a generated page, and the
  # Complete API appendix of a prose page.
  def generated_api_lines(content)
    generated, kind =
      if content.include?("\n## Complete API\n")
        [ content.split("\n## Complete API\n", 2).last, nil ]
      else
        [ content.split(/^## Properties$/, 2).last, "properties" ]
      end
    generated.lines.filter_map do |line|
      if line.start_with?("#")
        kind = case line
        when /Methods/ then "methods"
        when /Events/ then "events"
        when /properties/i then "properties"
        end
        next
      end
      name = line[/\A- `([a-z_0-9?!=]+)[`(]/, 1]
      [ kind, name, line ] if kind && name
    end
  end

  def documented_control?(slug)
    return true if DocsCatalog::SOURCE_ROOT.join("#{slug.tr('-', '_')}.md").exist?

    docs = DocsCatalog.control_docs[slug]
    docs.present? && docs["summary"].present? && Array(docs["example"]).any?(&:present?)
  end

  def catalog_pages
    slugs = DocsCatalog.control_catalog.map { |control| control[:slug] } +
      DocsCatalog.service_catalog.fetch(:services).map { |service| "service-#{service[:helper].tr('_', '-')}" }
    slugs.map { |slug| page(slug) }
  end

  # A page's Markdown, generated or read from its source file.
  def entry_text(entry)
    entry.content || (entry.source&.exist? ? entry.source.read : "")
  end

  def page_text(slug)
    entry_text(page(slug))
  end

  # The part of a page's Markdown above its generated API lists: the Complete
  # API appendix of a prose page, or the Properties list of a generated page.
  def hand_written(markdown)
    return markdown.split("\n## Complete API\n", 2).first if markdown.include?("\n## Complete API\n")

    markdown.split(/^## Properties$/, 2).first
  end

  STRING_KEY_SPAN = /`(["'])\w+\1`/
  STRING_KEY_HASH = /`\{\s*(["'])\w+\1\s*=>/
  PAYLOAD_KEY_INTRO = /(?:\bkeys?|`event\.data` has|\bhash with)\s+/

  # Code spans that name an event.data key as a String: in a key list ("has
  # the keys ...", "`event.data` has ...", "a hash with ...", to the end of the
  # sentence), in a hash literal of a sentence about `event.data`, or in a
  # bullet list under a line about `event.data` that ends with a colon. Values
  # may be Strings, so text in parentheses and a value list after a dash are
  # skipped.
  def string_payload_keys(markdown)
    in_payload_list = false
    markdown.gsub(/^```.*?^```$/m, "").split(/\n(?=- |\n)/).map(&:squish).reject(&:empty?).flat_map do |chunk|
      found = []
      if in_payload_list && chunk.start_with?("- ")
        found.concat(string_key_spans(chunk.gsub(/\([^()]*\)/, "").sub(/ — `.*\z/, "")))
      else
        in_payload_list = chunk.include?("`event.data`") && chunk.end_with?(":")
      end
      chunk.split(/(?<=[.;])\s+/).each do |sentence|
        keys = sentence.split(PAYLOAD_KEY_INTRO, 2)[1]
        found.concat(string_key_spans(keys.gsub(/\([^()]*\)/, ""))) if keys
        found << sentence[STRING_KEY_HASH] if sentence.include?("`event.data`") && sentence.match?(STRING_KEY_HASH)
      end
      found
    end
  end

  def string_key_spans(text)
    text.to_enum(:scan, STRING_KEY_SPAN).map { Regexp.last_match[0] }
  end

  # DocsCatalog.find falls back to the first page for an unknown slug, so a
  # missing page would otherwise pass as the Introduction.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end
end
