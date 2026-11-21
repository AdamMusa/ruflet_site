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
    control-arc control-audio control-banner-ad control-bar-chart control-bar-chart-group
    control-bar-chart-rod control-bar-chart-rod-stack-item control-block-picker
    control-candlestick-chart control-candlestick-chart-spot control-canvas control-chart-axis
    control-chart-axis-label control-circle control-circle-layer control-circle-marker control-color
    control-color-picker control-context-menu control-context-menu-action control-cupertino-app-bar
    control-cupertino-context-menu control-cupertino-context-menu-action
    control-cupertino-dialog-action control-cupertino-filled-button control-cupertino-navigation-bar
    control-cupertino-tinted-button control-fill control-filled-icon-button
    control-filled-tonal-icon-button control-hue-ring-picker control-image-source-attribution
    control-interstitial-ad control-line control-line-chart control-line-chart-data
    control-line-chart-data-point control-lottie control-map control-marker control-marker-layer
    control-material-picker control-menu-bar control-menu-item-button
    control-multiple-choice-block-picker control-native-ad control-navigation-bar-destination
    control-navigation-drawer-destination control-navigation-rail-destination
    control-outlined-icon-button control-oval control-path control-pie-chart
    control-pie-chart-section control-points control-polygon-layer control-polygon-marker
    control-polyline-layer control-polyline-marker control-radar-chart control-radar-chart-title
    control-radar-data-set control-radar-data-set-entry control-rect control-rich-attribution
    control-scatter-chart control-scatter-chart-spot control-shadow control-simple-attribution
    control-slide-picker control-step control-stepper control-submenu-button control-tab
    control-tab-bar control-tab-bar-view control-text-source-attribution control-tile-layer
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
    [ "control-checkbox", "properties", "spacing", "On Android, Windows and Linux, in a browser too, the 0.0.23 client ignores it." ],
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
    "control-range-slider" => [ "`label`, `round`, `inactive_color` and `overlay_color` apply on Android, Windows and Linux only" ],
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

  # The input controls' state readers (`event.control.value` and friends) are
  # on main only; each page that teaches `props[...]` names its reader once,
  # with the marker.
  STATE_READER_PROSE = {
    "control-auto-complete" => "`event.control.value` returns the same text",
    "control-checkbox" => "`event.control.value` (and `terms.value`)",
    "control-chip" => "`event.control.selected`",
    "control-cupertino-checkbox" => "`event.control.value` returns",
    "control-cupertino-date-picker" => "`event.control.value` returns the same moment",
    "control-cupertino-picker" => "`event.control.selected_index` returns",
    "control-cupertino-segmented-button" => "`event.control.selected_index` returns",
    "control-cupertino-slider" => "`event.control.value` returns",
    "control-cupertino-sliding-segmented-button" => "`event.control.selected_index` returns",
    "control-cupertino-switch" => "`event.control.value` returns",
    "control-cupertino-text-field" => "`event.control.selection` the same range",
    "control-cupertino-timer-picker" => "`event.control.value` returns",
    "control-date-picker" => "`event.control.entry_mode` return",
    "control-date-range-picker" => "`event.control.start_value` and `event.control.end_value`",
    "control-dropdown" => "`event.control.value` and `field.value`",
    "control-picker" => "`event.control.selected_index` returns",
    "control-radio-group" => "`event.control.value` and `choice.value`",
    "control-range-slider" => "`event.control.start_value` and `event.control.end_value`",
    "control-search-bar" => "`event.control.value` and `search.value`",
    "control-segmented-button" => "`event.control.selected` returns",
    "control-slider" => "`event.control.value` returns",
    "control-switch" => "`event.control.value` and `toggle.value`",
    "control-text-field" => "`field.selection` the same range",
    "control-time-picker" => "`event.control.entry_mode` return",
    "control-timer-picker" => "`event.control.value` returns"
  }.freeze

  # Generated lines of input controls that one design ignores, and the note
  # each must keep. Clients draw iOS and macOS with Cupertino widgets and
  # other platforms with Material ones, whichever helper built the control.
  # A web app follows the device the browser runs on (Flutter maps a browser
  # on an iPhone, iPad or Mac to iOS or macOS), so each note says so.
  PLATFORM_NOTES = {
    "material" => { "properties" => "iOS and macOS ignore it, in a browser too", "events" => "iOS and macOS never send it, in a browser too" },
    "cupertino" => { "properties" => "Android, Windows and Linux ignore it, in a browser too" }
  }.freeze
  PLATFORM_ONLY_LINES = {
    "control-checkbox" => { "material" => %w[hover_color overlay_color splash_radius visual_density] },
    "control-chip" => { "material" => %w[border_side check_color clip_behavior delete_drawer_animation_style delete_icon_color delete_icon_size_constraints elevation elevation_on_click enable_animation_style label_padding label_text_style leading_drawer_animation_style leading_size_constraints mouse_cursor select_animation_style selected_shadow_color shadow_color visual_density] },
    "control-cupertino-date-picker" => { "cupertino" => %w[date_order item_extent maximum_year minimum_year minute_interval show_day_of_week use_24h_format] },
    "control-cupertino-picker" => { "cupertino" => %w[default_selection_overlay_bgcolor diameter_ratio item_extent looping magnification off_axis_fraction selection_overlay squeeze use_magnifier] },
    "control-cupertino-radio" => { "cupertino" => %w[inactive_color use_checkmark_style] },
    "control-cupertino-segmented-button" => { "cupertino" => %w[border_color click_color disabled_color disabled_text_color selected_color unselected_color] },
    "control-cupertino-switch" => { "cupertino" => %w[off_label_color on_label_color] },
    "control-cupertino-text-field" => { "material" => %w[align_label_with_hint always_call_on_tap can_request_focus collapsed counter counter_style cursor_error_color dense focus_color helper helper_max_lines helper_style hint_fade_duration hint_max_lines hover_color icon ignore_pointers mouse_cursor prefix_icon prefix_icon_size_constraints prefix_style suffix_icon suffix_icon_size_constraints suffix_style], "cupertino" => %w[clear_button_semantics_label clear_button_visibility_mode placeholder_style prefix_visibility_mode suffix_visibility_mode] },
    "control-cupertino-timer-picker" => { "cupertino" => %w[item_extent] },
    "control-date-picker" => { "material" => %w[barrier_color entry_mode error_format_text error_invalid_text field_hint_text field_label_text inset_padding keyboard_type on_entry_mode_change switch_to_calendar_icon switch_to_input_icon], "cupertino" => %w[date_order item_extent maximum_year minimum_year minute_interval show_day_of_week use_24h_format] },
    "control-date-range-picker" => { "material" => %w[barrier_color current_date entry_mode error_format_text error_invalid_range_text error_invalid_text field_end_hint_text field_end_label_text field_start_hint_text field_start_label_text keyboard_type locale save_text switch_to_calendar_icon switch_to_input_icon] },
    "control-dropdown" => { "material" => %w[border_color border_width capitalization dense elevation enable_filter enable_search error_style error_text expanded_insets fill_color filled focused_border_color focused_border_width helper_style helper_text hint_style hover_color input_filter label_style menu_height menu_style menu_width selected_trailing_icon text_align text_size] },
    "control-picker" => { "cupertino" => %w[default_selection_overlay_bgcolor diameter_ratio item_extent looping magnification off_axis_fraction selection_overlay squeeze use_magnifier] },
    "control-radio" => { "material" => %w[hover_color overlay_color splash_radius visual_density], "cupertino" => %w[inactive_color use_checkmark_style] },
    "control-range-slider" => { "material" => %w[inactive_color mouse_cursor overlay_color round] },
    "control-search-bar" => { "material" => %w[bar_border_side bar_elevation bar_hint_text_style bar_overlay_color bar_padding bar_scroll_padding bar_shadow_color bar_shape bar_size_constraints bar_text_style capitalization divider_color full_screen keyboard_type shrink_wrap view_bar_padding view_bgcolor view_elevation view_header_height view_header_text_style view_hint_text view_hint_text_style view_leading view_padding view_shape view_side view_size_constraints view_trailing] },
    "control-segmented-button" => { "cupertino" => %w[border_color click_color disabled_color disabled_text_color selected_color unselected_color] },
    "control-slider" => { "material" => %w[inactive_color interaction mouse_cursor overlay_color round secondary_active_color secondary_track_value] },
    "control-switch" => { "material" => %w[active_color hover_color overlay_color padding splash_radius track_color], "cupertino" => %w[off_label_color on_label_color] },
    "control-text-field" => { "material" => %w[align_label_with_hint always_call_on_tap can_request_focus collapsed counter counter_style cursor_error_color dense focus_color helper helper_max_lines helper_style hint_fade_duration hint_max_lines hover_color icon ignore_pointers mouse_cursor prefix_icon prefix_icon_size_constraints prefix_style suffix_icon suffix_icon_size_constraints suffix_style], "cupertino" => %w[clear_button_semantics_label clear_button_visibility_mode placeholder_style prefix_visibility_mode suffix_visibility_mode] },
    "control-time-picker" => { "material" => %w[barrier_color entry_mode error_invalid_text help_text hour_label_text locale minute_label_text on_entry_mode_change orientation switch_to_input_icon switch_to_timer_icon] },
    "control-timer-picker" => { "cupertino" => %w[item_extent] }
  }.freeze

  test "input pages name their main-only state reader with the marker" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    STATE_READER_PROSE.each do |slug, phrase|
      paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase) }

      assert paragraph, "#{slug} no longer names its state reader (#{phrase.inspect})"
      assert_includes paragraph, marker, "#{slug}: the state reader needs the next-release marker"
      assert_includes paragraph, "with 0.0.23", "#{slug}: say what the reader does with 0.0.23"
    end
  end

  test "input lines one design ignores say so" do
    PLATFORM_ONLY_LINES.each do |slug, designs|
      lines = generated_api_lines(page(slug).content).to_h { |kind, name, line| [ name, [ kind, line ] ] }
      designs.each do |design, names|
        names.each do |name|
          kind, line = lines[name]

          assert line, "#{slug} renders no line for #{name}"
          assert_includes line, PLATFORM_NOTES.dig(design, kind), "#{slug} #{name} lost its platform note"
        end
      end
    end
  end

  # The input and form pages. Their hand-written text must not put "web" on
  # the Material side, and a page that splits by platform says once that a
  # web app follows the device it runs on.
  INPUT_PAGES = %w[
    control-auto-complete control-auto-complete-suggestion control-autofill-group control-checkbox
    control-chip control-cupertino-checkbox control-cupertino-date-picker control-cupertino-picker
    control-cupertino-radio control-cupertino-segmented-button control-cupertino-slider
    control-cupertino-sliding-segmented-button control-cupertino-switch control-cupertino-text-field
    control-cupertino-timer-picker control-date-picker control-date-range-picker control-dropdown
    control-dropdown-option control-form control-form-row control-option control-picker control-radio
    control-radio-group control-range-slider control-search-bar control-segment
    control-segmented-button control-slider control-switch control-text-field control-time-picker
    control-timer-picker
  ].freeze
  BROWSER_FOLLOWS_DEVICE = "A web app follows the device: in a browser on an iPhone, iPad or Mac it gets the iOS design.".freeze

  test "input pages say that a web app follows the device" do
    INPUT_PAGES.each do |slug|
      prose = prose_chunks(slug).join("\n")

      refute_match(/Android, web,|\bweb, Windows/, prose, "#{slug}: a browser on an Apple device draws the iOS design")
      next unless prose.match?(/iOS and macOS|Android, Windows and Linux/)

      assert_includes prose, BROWSER_FOLLOWS_DEVICE, "#{slug} splits by platform without saying what a browser gets"
    end
  end

  # Event data that is a Hash reaches Ruby with Symbol keys (the server runs
  # it through normalize_event_data), so `event.data["key"]` is always nil.
  test "input pages read Hash event data with Symbol keys" do
    INPUT_PAGES.each do |slug|
      text = page(slug).content

      refute_match(/event\.data\[\s*"/, text, "#{slug} reads event.data with a String key")
      refute_match(/`event\.data` is `\{ "/, text, "#{slug} shows event.data with String keys")
    end
  end

  # 0.0.23 parses String event data as JSON, so typed "42", a String key "1"
  # and a radio value "2" arrive as Integers, and so do a timer picker's
  # microseconds. Ruflet main (ruflet #103) keeps them Strings. Each page
  # scopes the parsing to 0.0.23 and says, with the marker, what main does.
  INPUT_PAYLOAD_NEXT_RELEASE = {
    "control-auto-complete" => "In the next release the typed text stays a String in both.",
    "control-cupertino-date-picker" => "In the next release the client reads `\"date_and_time\"` too",
    "control-cupertino-text-field" => "In the next release the typed text stays a String in both.",
    "control-cupertino-timer-picker" => "In the next release both are the String `\"90000000\"`.",
    "control-dropdown" => [
      "In the next release a String key stays a String, and an Integer key such as `1` still arrives as the Integer 1.",
      "Ruflet parses `on_text_change` data as JSON when it can"
    ],
    "control-radio-group" => "In the next release a String `value` stays a String, and an Integer `value` such as `2` still arrives as the Integer 2.",
    "control-search-bar" => "In the next release the query stays a String in both.",
    "control-text-field" => "In the next release the typed text stays a String in both.",
    "control-timer-picker" => "In the next release both are the String `\"90000000\"`."
  }.freeze

  test "input pages scope parsed event data to 0.0.23 and mark what main does" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    INPUT_PAGES.each do |slug|
      prose_chunks(slug).grep(/as JSON|arrives as the Integer|both the Integer|the Integer 90000000/).each do |chunk|
        assert_match(/with 0\.0\.23/i, chunk, "#{slug}: say that 0.0.23 parses this event data, not main: #{chunk}")
        assert_includes chunk, marker, "#{slug}: say what the next release sends instead: #{chunk}"
      end
    end
    INPUT_PAYLOAD_NEXT_RELEASE.each do |slug, phrases|
      Array(phrases).each do |phrase|
        paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase) }

        assert paragraph, "#{slug} no longer says #{phrase.inspect}"
        assert_includes paragraph, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
    %w[control-timer-picker control-cupertino-timer-picker].each do |slug|
      line = generated_line(slug, "events", "on_change")

      refute_includes line, "also an Integer", "#{slug} on_change: main sends the microseconds as a String"
      assert_includes line, "`.to_i` gives the number", "#{slug} on_change lost its .to_i advice"
    end
  end

  # A list item that calls event.data the typed text or query is true on main
  # only (ruflet #103); with 0.0.23 typed "42" arrives as 42. The item says so,
  # and so does each generated event line that says it.
  test "input list items that call event.data the typed text name the 0.0.23 parsing" do
    items = INPUT_PAGES.flat_map do |slug|
      lines = prose_chunks(slug).grep(/\A- /) + generated_api_lines(page(slug).content).map(&:last)
      lines.grep(/`event\.data` is the (text|query)\b/).map { |item| [ slug, item ] }
    end

    assert_operator items.size, :>=, 11
    items.each do |slug, item|
      assert_includes item, "with 0.0.23", "#{slug}: 0.0.23 parses typed text such as 42: #{item}"
    end
  end

  # With 0.0.23 Ruflet copies parsed event data to `value` only on a change
  # event, and the client sends one only while the control has `on_change`
  # (ruflet_backend.dart checks `on_<event>`). Otherwise `update_control` keeps
  # the String, and a Material search bar writes it again before `on_submit`.
  PROPS_VALUE_EITHER = "`props[\"value\"]` can then be the Integer 42 or the String `\"42\"`".freeze

  test "input pages say that with 0.0.23 props value can stay the typed String" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    %w[control-auto-complete control-cupertino-text-field control-search-bar control-text-field].each do |slug|
      paragraph = prose_chunks(slug).find { |chunk| chunk.include?(PROPS_VALUE_EITHER) }

      assert paragraph, "#{slug}: with 0.0.23 props[\"value\"] is the Integer only after a change event"
      assert_match(/only on a change event, which the client sends only while the (field|bar|control) has `on_change`/, paragraph)
      assert_includes paragraph, marker
    end
    assert_includes prose_chunks("control-search-bar").join("\n"), "on Android, Windows and Linux the bar writes the String again just before `on_submit`"
    INPUT_PAGES.each do |slug|
      text = (prose_chunks(slug) + generated_api_lines(page(slug).content).map(&:last)).join("\n")

      refute_match(/Integer 42 in `event\.data` and in `props\["value"\]`/, text, "#{slug}: with 0.0.23 props[\"value\"] keeps the String without a change event")
    end
  end

  # The 0.0.23 client reads an `{ all: n }` padding map as 0 and throws on a
  # named alignment such as "center" (ruflet-engine #119 reads both on the
  # engine branch). Input page examples use numbers and `{ x:, y: }` maps, and
  # every line that shows those shapes names the 0.0.23 behavior.
  test "input pages show all-maps and named alignments only with their 0.0.23 caveat" do
    INPUT_PAGES.each do |slug|
      content = page(slug).content
      content.scan(/^```ruby\n(.*?)^```/m).flatten.each_with_index do |code, index|
        refute_match(/\ball:\s/, code, "#{slug} Ruby block #{index + 1}: the 0.0.23 client reads { all: n } as 0")
        refute_match(/alignment:\s*[":]/, code, "#{slug} Ruby block #{index + 1}: the 0.0.23 client cannot read a named alignment")
      end
      (prose_chunks(slug) + generated_api_lines(content).map(&:last)).grep(/\{ all: \d+ \}|alignment: "/).each do |chunk|
        assert_includes chunk, "0.0.23", "#{slug}: say what 0.0.23 does with this shape: #{chunk}"
      end
    end
    example = page("control-cupertino-timer-picker").content[/^## Example\n\n```ruby\n(.*?)^```/m, 1]

    assert_includes example, "alignment: { x: 0, y: 0 }", "0.0.23 shows an error box for the helper's default alignment on iOS and macOS"
  end

  # Earlier statements a review found wrong on both releases.
  test "input pages keep the payload and option fixes a review made" do
    disabled = generated_line("control-dropdown-option", "properties", "disabled")

    refute_includes disabled, "still offer", "the next release dims a disabled option on iOS and macOS"
    assert_includes disabled, "the 0.0.23 client still lets the user pick it there."
    assert_includes generated_line("control-dropdown", "events", "on_change"), "the same `event.data`, the option's key"
    range = prose_chunks("control-date-range-picker").join("\n")

    assert_includes range, "and not from `event.data`: on Android, Windows and Linux it is an empty String."
    refute_match(/`event\.data` holds them/, range, "on Android, Windows and Linux the range picker's event.data is an empty String")
    assert_includes prose_chunks("control-chip").join("\n"), "a bare icon name such as `\"star\"` draws nothing"
    assert_includes generated_line("control-chip", "properties", "leading"), "A bare icon name such as `\"star\"` draws nothing."
    form_change = generated_line("control-form", "events", "on_change")

    assert_includes form_change, "once the field's own handler has run", "Form on_change lost its own description"
    assert_includes form_change, "`event.control` is the form"
    timer = prose_chunks("control-cupertino-timer-picker").join("\n")

    assert_includes timer, "and so they are when you leave `value` out, because this helper sends `value: 0`"
    refute_includes timer, "Without one they are both", "cupertino_timer_picker sends value: 0, so leaving it out still reports seconds"
  end

  # What 0.0.23 rejects (ruflet #109) and the shapes its client misreads
  # (ruflet-engine #119). Each hand-written note carries the marker.
  INPUT_RELEASE_PROSE = {
    "control-segmented-button" => "with 0.0.23, `page.update(button, show_selected_icon: false)` raises ArgumentError",
    "control-cupertino-timer-picker" => "the 0.0.23 client cannot read the `alignment: \"center\"` this helper sends by default",
    "control-cupertino-text-field" => "the 0.0.23 client reads the `{ all: 7 }` padding this helper sends, and any `{ all: n }` map, as no padding",
    "control-timer-picker" => "With 0.0.23 a named alignment such as `\"center\"` shows Flutter's error box"
  }.freeze

  # Generated lines whose per-name note in config/next_release.json says what
  # works with 0.0.23 first, so the sentence right before the marker is the
  # one that needs the next release.
  INPUT_RELEASE_NOTE_ENDINGS = {
    [ "control-text-field", "padding" ] => "In the next release it reads `{ all: n }` there as n on every side.",
    [ "control-cupertino-text-field", "padding" ] => "In the next release it reads `{ all: n }` there as n on every side.",
    [ "control-timer-picker", "alignment" ] => "In the next release it reads named alignments such as `\"center\"` there too.",
    [ "control-cupertino-timer-picker", "alignment" ] => "In the next release it reads named alignments such as `\"center\"` there too."
  }.freeze

  test "input pages keep their 0.0.23 notes on rejected keys and misread shapes" do
    marker = DocsCatalog::NEXT_RELEASE_MARKER

    INPUT_RELEASE_PROSE.each do |slug, phrase|
      paragraph = prose_chunks(slug).find { |chunk| chunk.include?(phrase) }

      assert paragraph, "#{slug} no longer says #{phrase.inspect}"
      assert_includes paragraph, marker, "#{slug}: #{phrase.inspect} needs the next-release marker"
    end
    INPUT_RELEASE_NOTE_ENDINGS.each do |(slug, name), ending|
      line = generated_line(slug, "properties", name)

      assert_includes line, "#{ending} #{marker}.", "#{slug} #{name}: end the note with what the next release does"
      refute_match(/works there\. \*\*Requires/, line, "#{slug} #{name}: the marker must follow the main-only sentence")
    end
    show_icon = generated_line("control-segmented-button", "properties", "show_selected_icon")

    assert_includes show_icon, "with 0.0.23 `page.update` of this key raises ArgumentError", "ruflet #109"
    refute_includes show_icon, marker, "setting show_selected_icon when building the button works on 0.0.23"
  end

  # Like FULLY_DESCRIBED_CONTROLS, for the input and form controls: every
  # property and event line has its own description.
  test "input controls describe every property and event" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    catalog = DocsCatalog.control_catalog.index_by { |control| control[:slug] }

    missing = INPUT_PAGES.flat_map do |slug|
      control = catalog[slug]
      next [ "#{slug}: not in the catalog" ] unless control

      %w[properties events].flat_map do |kind|
        Array(control[kind.to_sym]).map(&:to_s).reject do |name|
          descriptions.dig("widget_overrides", control[:widget_type].to_s, name) || descriptions.dig(kind, name)
        end.map { |name| "#{slug} #{kind} #{name}" }
      end
    end

    assert_empty missing, "Describe these in config/property_descriptions.json:\n#{missing.join("\n")}"
  end

  # A hand-written list item carries the marker only for names that
  # config/next_release.json lists for its page: the other names work on 0.0.23.
  test "input list items carry the marker only for names next_release.json lists" do
    config = JSON.parse(Rails.root.join("config/next_release.json").read)
    marker = DocsCatalog::NEXT_RELEASE_MARKER
    listed = next_release_lists(config).group_by { |_list, slug, _kind, _name| slug }.transform_values { |rows| rows.map(&:last) }

    wrong = (INPUT_PAGES - config.fetch("controls")).flat_map do |slug|
      prose_chunks(slug).grep(/\A- `/).select { |item| item.include?(marker) }.filter_map do |item|
        names = item[/\A- ((?:`[a-z_0-9]+`(?: \/ | and |, )?)+)/, 1].to_s.scan(/`([a-z_0-9]+)`/).flatten
        "#{slug}: #{item}" if names.empty? || (names - listed.fetch(slug, [])).any?
      end
    end

    assert_empty wrong, "List these names in config/next_release.json, or drop the marker:\n#{wrong.join("\n")}"
  end

  # A Ruby example that forgets to define a name still compiles: Ruby parses
  # the name as a method call. Every receiverless call in these examples must
  # be a Ruflet helper or one of the Kernel methods below.
  EXAMPLE_KERNEL_CALLS = %w[page lambda proc format puts raise Integer Float String Array].freeze

  test "input page examples define every name they use" do
    require "prism"
    helpers = DocsCatalog.control_catalog.flat_map { |control| Array(control[:helpers]) }
    allowed = (helpers + EXAMPLE_KERNEL_CALLS).to_set

    INPUT_PAGES.each do |slug|
      page(slug).content.scan(/^```ruby\n(.*?)^```/m).flatten.each_with_index do |code, index|
        unknown = receiverless_calls(Prism.parse(code).value).reject { |name| allowed.include?(name) }

        assert_empty unknown.uniq, "#{slug} Ruby block #{index + 1} uses names it never defines"
      end
    end
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

  # Names called without a receiver anywhere in a Prism tree.
  def receiverless_calls(node)
    calls = node.is_a?(Prism::CallNode) && node.receiver.nil? ? [ node.name.to_s ] : []
    node.compact_child_nodes.each { |child| calls.concat(receiverless_calls(child)) }
    calls
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
