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
    control-about-dialog control-absorb-pointer control-action-sheet control-action-sheet-action
    control-arc control-audio
    control-banner-ad control-bar-chart control-bar-chart-group control-bar-chart-rod
    control-bar-chart-rod-stack-item control-block-picker control-candlestick-chart
    control-candlestick-chart-spot control-canvas control-carousel-view control-chart-axis
    control-chart-axis-label control-circle control-circle-layer control-circle-marker
    control-clip-oval control-clip-r-superellipse control-color control-color-picker
    control-context-menu control-context-menu-action control-cupertino-action-sheet
    control-cupertino-action-sheet-action control-cupertino-activity-indicator
    control-cupertino-alert-dialog control-cupertino-app-bar control-cupertino-bottom-sheet
    control-cupertino-context-menu control-cupertino-context-menu-action
    control-cupertino-dialog-action control-cupertino-filled-button
    control-cupertino-list-tile control-cupertino-navigation-bar
    control-cupertino-tinted-button control-custom-scroll-view control-data-cell control-data-column
    control-data-column-2 control-data-row control-data-row-2 control-data-table-2
    control-drag-target control-draggable control-draggable-scrollable-sheet
    control-expansion-panel control-expansion-panel-list control-fade-transition control-fill
    control-filled-icon-button control-filled-tonal-icon-button control-fitted-box
    control-fractionally-sized-box control-hero control-hue-ring-picker
    control-ignore-pointer control-image-source-attribution control-indexed-stack
    control-interactive-viewer control-interstitial-ad control-intrinsic-height
    control-intrinsic-width control-keyboard-listener control-line control-line-chart
    control-line-chart-data control-line-chart-data-point control-list-section control-lottie
    control-map control-marker control-marker-layer control-material-picker control-menu-bar
    control-menu-item-button control-merge-semantics control-multiple-choice-block-picker
    control-native-ad control-navigation-bar-destination control-navigation-drawer-destination
    control-navigation-rail-destination control-nested-scroll-view
    control-outlined-icon-button control-oval control-overlay control-path
    control-pie-chart control-pie-chart-section control-placeholder control-points
    control-polygon-layer control-polygon-marker control-polyline-layer control-polyline-marker
    control-radar-chart control-radar-chart-title control-radar-data-set
    control-radar-data-set-entry control-rect control-reorderable-drag-handle
    control-rich-attribution control-rotated-box control-rotation-transition control-ruflet-app
    control-scale-transition control-scatter-chart control-scatter-chart-spot control-screenshot
    control-selection-area control-semantics control-shader-mask control-shadow control-shimmer
    control-simple-attribution control-size-transition control-slide-picker control-slide-transition
    control-sliver-app-bar control-sliver-fill-remaining control-sliver-grid control-sliver-list
    control-sliver-padding control-sliver-to-box-adapter control-snack-bar-action control-step
    control-stepper control-submenu-button control-tab control-tab-bar control-tab-bar-view
    control-table control-table-row control-text-source-attribution control-text-span
    control-tile-layer control-transparent-pointer control-vertical-divider
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

  # DocsCatalog.find falls back to the first page for an unknown slug, so a
  # missing page would otherwise pass as the Introduction.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end
end
