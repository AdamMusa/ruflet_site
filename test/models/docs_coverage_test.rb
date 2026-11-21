require "test_helper"

# Every Ruflet control and service the reference lists must be documented.
# The test reads only the site's own files (config/*.json, app/content/docs and
# DocsCatalog), so it runs offline and without a Ruflet checkout.
class DocsCoverageTest < ActiveSupport::TestCase
  # Controls that still have only a generated page. The list may only shrink:
  # document a control (a page or a config/control_docs.json entry) and then
  # remove it here. A listed control that gains docs does not fail the test,
  # so pages can land in any order.
  PENDING_CONTROLS = %w[
    control-absorb-pointer
    control-arc control-audio control-auto-complete-suggestion control-autofill-group
    control-banner-ad control-bar-chart control-bar-chart-group control-bar-chart-rod
    control-bar-chart-rod-stack-item control-block-picker control-candlestick-chart
    control-candlestick-chart-spot control-canvas control-carousel-view control-chart-axis
    control-chart-axis-label control-circle control-circle-layer control-circle-marker
    control-clip-oval control-clip-r-superellipse control-color control-color-picker
    control-cupertino-checkbox
    control-cupertino-picker
    control-cupertino-radio control-cupertino-slider control-cupertino-timer-picker
    control-custom-scroll-view
    control-drag-target control-draggable control-draggable-scrollable-sheet control-dropdown-option
    control-fade-transition control-fill
    control-fitted-box control-form
    control-form-row control-fractionally-sized-box control-hero control-hue-ring-picker
    control-ignore-pointer control-image-source-attribution control-indexed-stack
    control-interactive-viewer control-interstitial-ad control-intrinsic-height
    control-intrinsic-width control-keyboard-listener control-line control-line-chart
    control-line-chart-data control-line-chart-data-point control-lottie
    control-map control-marker control-marker-layer control-material-picker
    control-merge-semantics control-multiple-choice-block-picker
    control-native-ad
    control-nested-scroll-view control-option
    control-oval control-overlay control-path control-picker
    control-pie-chart control-pie-chart-section control-placeholder control-points
    control-polygon-layer control-polygon-marker control-polyline-layer control-polyline-marker
    control-radar-chart control-radar-chart-title control-radar-data-set
    control-radar-data-set-entry control-rect control-reorderable-drag-handle
    control-rich-attribution control-rotated-box control-rotation-transition control-ruflet-app
    control-scale-transition control-scatter-chart control-scatter-chart-spot control-screenshot
    control-selection-area control-semantics control-shader-mask control-shadow control-shimmer
    control-simple-attribution control-size-transition control-slide-picker control-slide-transition
    control-sliver-app-bar control-sliver-fill-remaining control-sliver-grid control-sliver-list
    control-sliver-padding control-sliver-to-box-adapter
    control-text-source-attribution control-text-span
    control-tile-layer control-timer-picker control-transparent-pointer control-vertical-divider
    control-video control-window-drag-area
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
  # on iOS and macOS) main does not run them either.
  PINNED_RELEASED_LINES = [
    [ "control-reorderable-list-view", "events", "on_scroll" ],
    [ "control-reorderable-list-view", "properties", "scroll_interval" ],
    [ "control-context-menu", "methods", "open" ],
    [ "control-popup-menu-button", "events", "on_select" ]
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
    "control-popup-menu-button" => [ "fires `on_cancel` when the sheet closes" ],
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
  # config/property_descriptions.json, never the generated "Sets the X
  # property." or "Fired on X.". The list may only grow.
  FULLY_DESCRIBED_CONTROLS = %w[
    control-about-dialog control-action-sheet control-action-sheet-action control-alert-dialog
    control-banner control-bottom-sheet control-cupertino-action-sheet
    control-cupertino-action-sheet-action control-cupertino-activity-indicator
    control-cupertino-alert-dialog control-cupertino-bottom-sheet control-cupertino-list-tile
    control-data-cell control-data-column control-data-column-2 control-data-row control-data-row-2
    control-data-table control-data-table-2 control-expansion-panel control-expansion-panel-list
    control-expansion-tile control-list-section control-list-tile control-progress-bar
    control-progress-ring control-snack-bar control-snack-bar-action control-spinkit control-table
    control-table-row
  ].freeze

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
  STRING_KEY_PAYLOAD_PAGES = %w[control-draggable-scrollable-sheet control-qrcode-scanner qrcode-scanner].freeze

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
test "examples on fully described pages spell color names without underscores" do
  offenders = FULLY_DESCRIBED_CONTROLS.flat_map do |slug|
    page(slug).content.scan(/\b\w*color: *(?::|")[a-z]+_[a-z0-9_]*/).map { |hit| "#{slug}: #{hit}" }
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
    [ "control-context-menu", "events", "on_select", "symbol keys" ],
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

  private

  # The hand-written part of a page (everything above a prose page's Complete
  # API appendix), split into paragraphs and list items, each on one line.
  def prose_chunks(slug)
    page(slug).content.split("\n## Complete API\n", 2).first.split(/\n(?=- |\n)/).map(&:squish)
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

  # DocsCatalog.find falls back to the first page for an unknown slug, so a
  # missing page would otherwise pass as the Introduction.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end
end
