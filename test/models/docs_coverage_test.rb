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
    control-about-dialog control-action-sheet control-action-sheet-action
    control-arc control-audio control-auto-complete-suggestion control-autofill-group
    control-banner-ad control-bar-chart control-bar-chart-group control-bar-chart-rod
    control-bar-chart-rod-stack-item control-block-picker control-candlestick-chart
    control-candlestick-chart-spot control-canvas control-chart-axis
    control-chart-axis-label control-circle control-circle-layer control-circle-marker
    control-color control-color-picker
    control-context-menu control-context-menu-action control-cupertino-action-sheet
    control-cupertino-action-sheet-action control-cupertino-activity-indicator
    control-cupertino-alert-dialog control-cupertino-app-bar control-cupertino-bottom-sheet
    control-cupertino-checkbox control-cupertino-context-menu control-cupertino-context-menu-action
    control-cupertino-dialog-action control-cupertino-filled-button
    control-cupertino-list-tile control-cupertino-navigation-bar control-cupertino-picker
    control-cupertino-radio control-cupertino-slider control-cupertino-timer-picker
    control-cupertino-tinted-button control-data-cell control-data-column
    control-data-column-2 control-data-row control-data-row-2 control-data-table-2
    control-dropdown-option
    control-expansion-panel control-expansion-panel-list control-fill
    control-filled-icon-button control-filled-tonal-icon-button control-form
    control-form-row control-hue-ring-picker
    control-image-source-attribution
    control-interstitial-ad
    control-line control-line-chart
    control-line-chart-data control-line-chart-data-point control-list-section control-lottie
    control-map control-marker control-marker-layer control-material-picker control-menu-bar
    control-menu-item-button control-multiple-choice-block-picker
    control-native-ad control-navigation-bar-destination control-navigation-drawer-destination
    control-navigation-rail-destination control-option
    control-outlined-icon-button control-oval control-path control-picker
    control-pie-chart control-pie-chart-section control-points
    control-polygon-layer control-polygon-marker control-polyline-layer control-polyline-marker
    control-radar-chart control-radar-chart-title control-radar-data-set
    control-radar-data-set-entry control-rect
    control-rich-attribution
    control-scatter-chart control-scatter-chart-spot
    control-shadow
    control-simple-attribution control-slide-picker
    control-snack-bar-action control-step
    control-stepper control-submenu-button control-tab control-tab-bar control-tab-bar-view
    control-table control-table-row control-text-source-attribution
    control-tile-layer control-timer-picker
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
    "control-data-table" => [ "the 0.0.23 client draws no checkbox column", "the 0.0.23 client also ignores `vertical_lines`" ],
    "control-banner" => [ "On iOS and macOS, the 0.0.23 client never sends it." ],
    "control-bottom-sheet" => [ "`fullscreen` — on iOS and macOS these need the" ],
    "control-popup-menu-button" => [ "fires `on_cancel` when the sheet closes" ],
    "control-search-bar" => [ "On iOS and macOS, `open_view` focuses the bar", "with 0.0.23 both do nothing there" ],
    "control-list-tile" => [ "there `selected` only tells screen readers" ],
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
      "`event.data[\"asc\"]` is the new direction on Android, web, Windows and Linux.",
      "On iOS and macOS it is the table's current `sort_ascending`"
    ],
    "control-list-tile" => [
      "`dense` / `is_three_line` — Android, web, Windows and Linux only",
      "`hover_color` — Android, web, Windows and Linux only",
      "`shape` — Android, web, Windows and Linux only"
    ],
    "control-bottom-sheet" => [ "`shape` / `elevation` — Android, web, Windows and Linux only" ],
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

  # Controls whose every property and event line has a written description (a
  # widget override or a shared entry in config/property_descriptions.json) and
  # whose every method has a method note, instead of the generated fallback.
  # The list may only grow.
  FULLY_DESCRIBED_CONTROLS = %w[
    control-absorb-pointer control-animated-switcher control-badge control-card control-carousel-view
    control-circle-avatar control-clip-oval control-clip-r-superellipse control-column control-container
    control-custom-scroll-view control-dismissible control-divider control-drag-target control-draggable
    control-draggable-scrollable-sheet control-fade-transition control-fitted-box
    control-fractionally-sized-box control-gesture-detector control-grid-view control-hero control-icon
    control-ignore-pointer control-image control-indexed-stack control-interactive-viewer
    control-intrinsic-height control-intrinsic-width control-keyboard-listener control-list-view
    control-markdown control-merge-semantics control-nested-scroll-view control-overlay control-page-view
    control-placeholder control-reorderable-drag-handle control-reorderable-list-view
    control-responsive-row control-rotated-box control-rotation-transition control-row control-ruflet-app
    control-safe-area control-scale-transition control-screenshot control-selection-area control-semantics
    control-shader-mask control-shimmer control-size-transition control-slide-transition
    control-sliver-app-bar control-sliver-fill-remaining control-sliver-grid control-sliver-list
    control-sliver-padding control-sliver-to-box-adapter control-stack control-text control-text-span
    control-transparent-pointer control-vertical-divider control-window-drag-area
  ].freeze

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
    assert_includes events.fetch("on_scroll"), "`:event_type`"
    assert_includes events.fetch("on_end_reached"), "the keys `:pixels`"
    %w[opacity rotation scale offset align margin position container].each do |name|
      assert_includes events.fetch("on_animation_end"), "`\"#{name}\"`"
    end
  end

  # Hand-written sentences of the layout pages that describe main-only
  # behavior (each must carry the marker) or one design only (each must stay).
  LAYOUT_PROSE_MARKERS = {
    "controls-and-layout" => [
      "Snake case, such as `\"space_between\"`, also works on Ruflet main",
      "On Ruflet main these alignments also take a name",
      "lays out its children like a `column`, so `expand` works inside it too"
    ],
    "control-row" => [ "`on_end_reached`, `end_reached_threshold` and `keyboard_dismiss_behavior` work on a scrolling row too" ],
    "control-container" => [ "`opacity_on_click` — the opacity an `ink: true` container fades to" ],
    "control-image" => [ "`src_base64:` is the same data under its own name" ],
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
    "control-reorderable-list-view" => [ "`semantic_child_count` is accepted, but no Ruflet client reads it" ]
  }.freeze

  # Sections of hand-written layout pages that need the next release: each
  # heading must be followed directly by the callout.
  LAYOUT_SECTION_CALLOUTS = {
    "control-column" => "Refreshing and loading more",
    "control-list-view" => "Refreshing and loading more",
    "control-grid-view" => "Refreshing and loading more"
  }.freeze

  test "main-only sections of layout pages open with the callout" do
    callout = "> #{DocsCatalog::NEXT_RELEASE_MARKER}."

    LAYOUT_SECTION_CALLOUTS.each do |slug, heading|
      section = page(slug).content[/^## #{Regexp.escape(heading)}\n\n(.*?)(?=^## |\z)/m, 1]

      assert section, "#{slug} has no ## #{heading} section"
      assert section.start_with?(callout), "#{slug}: ## #{heading} needs the next-release callout right under the heading"
    end

    example = page("control-semantics").content[/^## Example\n\n(.*?)^```ruby/m, 1]
    assert_includes example.to_s, callout, "The 0.0.23 client draws nothing for semantics, so its example needs the callout"
  end

  test "layout pages read event payloads with symbol keys and decorate text with constants" do
    slugs = FULLY_DESCRIBED_CONTROLS + %w[controls-and-layout]
    string_keys = slugs.select { |slug| page_text(slug).match?(/\bevent\.data\[["']/) }
    string_decorations = DocsCatalog.all_entries.select { |entry| entry_text(entry).match?(/\bdecoration: ["']/) }.map(&:slug)

    assert_empty string_keys, "The server gives event.data hashes Symbol keys, so read event.data[:key]: #{string_keys.join(', ')}"
    assert_empty string_decorations, "Clients read decoration as a Ruflet::TextDecoration bit mask; a String draws nothing: #{string_decorations.join(', ')}"
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

  # A page's Markdown, generated or read from its source file.
  def entry_text(entry)
    entry.content || (entry.source&.exist? ? entry.source.read : "")
  end

  def page_text(slug)
    entry_text(page(slug))
  end

  # DocsCatalog.find falls back to the first page for an unknown slug, so a
  # missing page would otherwise pass as the Introduction.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end
end
