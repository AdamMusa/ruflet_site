require "test_helper"

# The service pages, the Page reference, the events page and the API reference
# must document every member the Ruflet API lists. Like docs_coverage_test.rb,
# this reads only the site's own files, so it runs offline.
class DocsRuntimeReferenceTest < ActiveSupport::TestCase
  # Ruflet::UI::Controls::RufletComponents::PageControl::KEYWORDS and
  # WindowControl::KEYWORDS (identical in 0.0.23 and on main). The catalogs
  # do not list the Page and Window controls, so they are copied here.
  PAGE_KEYWORDS = %w[
    adaptive badge client_ip client_user_agent col dark_theme data debug disabled enable_screenshots
    expand expand_loose fonts height key locale_configuration media multi_view multi_views opacity
    platform platform_brightness pwa pyodide route rtl sess show_semantics_debugger test theme
    theme_mode title tooltip views visible wasm web width window on_app_lifecycle_state_change
    on_close on_connect on_disconnect on_error on_keyboard_event on_locale_change on_login on_logout
    on_media_change on_multi_view_add on_multi_view_remove on_platform_brightness_change on_resize
    on_route_change on_view_pop
  ].freeze
  WINDOW_KEYWORDS = %w[
    alignment always_on_bottom always_on_top aspect_ratio badge_label bgcolor brightness data focused
    frameless full_screen height icon ignore_mouse_events key left max_height max_width maximizable
    maximized min_height min_width minimizable minimized movable opacity prevent_close progress_bar
    resizable shadow skip_task_bar title_bar_buttons_hidden title_bar_hidden top visible width on_event
  ].freeze
  WINDOW_METHODS = %w[center close destroy to_front wait_until_ready_to_show start_dragging start_resizing].freeze
  # The View keywords the page explains itself; the rest are listed by name
  # and documented on the View control page.
  VIEW_KEYWORDS = %w[
    route can_pop on_confirm_pop fullscreen_dialog decoration foreground_decoration
    floating_action_button_location scroll_interval on_scroll services
  ].freeze
  MARKER = DocsCatalog::NEXT_RELEASE_MARKER

  test "every service property, event and method line has its own description" do
    undescribed = []

    DocsCatalog.service_catalog.fetch(:services).each do |service|
      slug = "service-#{service[:helper].tr('_', '-')}"
      sections = page(slug).content.split(/^## /).to_h { |chunk| [ chunk.lines.first.to_s.strip, chunk ] }
      { "Properties" => service[:properties], "Events" => service[:events] }.each do |heading, names|
        Array(names).each do |name|
          line = sections.fetch(heading).lines.find { |candidate| candidate.start_with?("- `#{name}` — ") }
          description = line.to_s.split(" — ", 2).last.to_s.strip
          undescribed << "#{slug} #{heading.downcase} #{name}" if line.nil? || generic_description?(name, description)
        end
      end
      %w[Service\ methods Page\ proxy\ methods Page\ convenience\ methods].each do |heading|
        next unless sections.key?(heading)

        sections[heading].lines.select { |line| line.start_with?("- `") }.each do |line|
          undescribed << "#{slug} #{heading.downcase}: #{line.strip}" unless line.include?("` — ")
        end
      end
    end

    assert_empty undescribed, <<~MESSAGE
      Describe these in the "services" (or "page") section of config/property_descriptions.json:
      #{undescribed.join("\n")}
    MESSAGE
  end

  test "service descriptions only name members the catalog lists" do
    catalog = DocsCatalog.service_catalog.fetch(:services).index_by { |service| service[:helper] }
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read)
    stale = []

    descriptions.fetch("services").each do |helper, kinds|
      service = catalog[helper]
      next stale << helper unless service

      kinds.each do |kind, names|
        known = case kind
        when "properties" then service[:properties]
        when "events" then service[:events]
        when "methods" then Array(service[:methods]).map { |method| method[:name] }
        when "proxy_methods" then Array(service[:proxy_methods]).map { |method| method[:name] }
        end
        next stale << "#{helper} #{kind}" if known.nil?

        (names.keys - Array(known).map(&:to_s)).each { |name| stale << "#{helper} #{kind} #{name}" }
      end
    end
    convenience = DocsCatalog::SERVICE_CONVENIENCE_METHODS.values.flatten
    (descriptions.fetch("page").keys - convenience).each { |name| stale << "page #{name}" }

    assert_empty stale, "config/property_descriptions.json describes members the catalogs do not list: #{stale.join(', ')}"
  end

  test "the Page reference names every Page, View and Window keyword and method" do
    content = page("page-reference").content
    missing = (PAGE_KEYWORDS + WINDOW_KEYWORDS + WINDOW_METHODS + VIEW_KEYWORDS).uniq.reject do |name|
      named?(content, name) || (name.start_with?("on_") && named?(content, name.delete_prefix("on_")))
    end
    view_keywords = DocsCatalog.control_catalog.find { |control| control[:slug] == "control-view" }
    page_methods = DocsCatalog.runtime_catalog.fetch(:page).map { |method| method[:name].to_s }
    documented_page_methods = %w[
      add insert remove remove_at clean controls update schedule_update patch_page get_control set_view_props mount
      go navigate push_route query on_route_change= on_view_pop= on_views_pop_until= pop_views_until
      show_dialog open close_dialog close pop_dialog show_snack_bar show_snackbar show_bottom_sheet show_bottomsheet
      close_bottom_sheet close_bottomsheet show_banner close_banner show_drawer close_drawer show_end_drawer close_end_drawer
      scroll_to service add_service remove_service invoke invoke_sync on get_device_info get_device_info_sync
      set_allowed_device_orientations web session_id client_details
    ] & page_methods

    assert view_keywords, "the catalog has no View control"
    assert_empty missing, "page_reference.md does not name: #{missing.join(', ')}"
    documented_page_methods.each do |name|
      assert content.match?(/`(page\.)?#{Regexp.escape(name.delete_suffix('='))}[`(= ]/), "page_reference.md does not describe page.#{name}"
    end
  end

  test "the events page names every event payload class" do
    content = page("events-and-state").content
    missing = DocsCatalog.runtime_catalog.fetch(:event_payloads).map { |payload| payload[:name] }.reject do |name|
      content.include?("`#{name}`") || content.include?("`Ruflet::Events::#{name}`")
    end

    assert_empty missing, "events_and_state.md does not name these Ruflet::Events classes: #{missing.join(', ')}"
    assert_includes content, "EVENT_CLASS_MAP"
  end

  test "the API reference names every value type and constant module" do
    content = page("reference").content
    names = DocsCatalog.runtime_catalog.fetch(:value_types).map { |type| type[:name] } +
      DocsCatalog.runtime_catalog.fetch(:constant_modules).map { |mod| mod[:name] }
    missing = names.reject { |name| content.include?(name) || content.include?("Ruflet::#{name.split('::').last}") }

    assert_empty missing, "reference.md does not name: #{missing.join(', ')}"
  end

  # Sentences about behavior that only Ruflet main has, pinned to the marker.
  PINNED_MARKERS = {
    "page-reference" => [
      "`pop_views_until(route, result: nil)`", "`views_pop_until`", "`get_device_info(on_result:)`", "handler writer such as",
      "are View keywords on `main` only"
    ],
    "events-and-state" => [
      "`ActionResultEvent`", "`PasteFilesEvent`", "`ViewsPopUntilEvent`", "`event.with_name(name)`",
      "`event.control.value` raises NoMethodError", "`page.pop_views_until(route, result: nil)` pops",
      "Any `page.on_<event> =` writer registers", "`event.relayed(name:, target:, control:)`",
      "such as typed text or a picked option, stays that String"
    ],
    "services-and-plugins" => [ "`local_authentication.authenticate` waits 60 seconds" ],
    "theming" => [ "A style also takes `font_family_fallback`" ],
    "reference" => [ "also ignores `font_family_fallback:`" ],
    "service-geolocator" => [ "on `main` it receives the error too" ],
    "service-audio-recorder" => [ "such a name, or none, arrives as the error", "`device` also takes the id alone" ]
  }.freeze

  # The server symbolizes the keys of an event's Hash payload, nested Hashes
  # included, so a String key is always nil in a real app: event.data["state"],
  # values_at("x"), event.data[:position]["latitude"],
  # event.data.fetch(:state)["x"], or data = event.data; data["state"].
  # Symbol, Integer and method steps (event.data[:locales].first) may come
  # before the String key.
  PAYLOAD_STEPS = /(?:\[[^\]"']*\]|&?\.(?:fetch|dig)\([^)"']*\)|&?\.(?:first|last))*/
  STRING_KEY = /(?:&?\[\s*["']|&?\.(?:values_at|dig|fetch|key\?)\(\s*["']|&?\.(?:values_at|dig)\([^)]*["'])/
  STRING_KEY_READ = /\.data#{PAYLOAD_STEPS}#{STRING_KEY}/
  # A local that holds the payload or part of it: data = event.data[:position]
  PAYLOAD_ALIAS = /(?<![\w.])([a-z_]\w*)\s*=(?![=~>])\s*[a-z_]\w*\.data\b#{PAYLOAD_STEPS}\s*(?:$|[;)}|]|\|\||or\b|&&)/

  test "the String-key check catches direct, chained and aliased reads" do
    wrong = [
      'event.data["connectivity"]', "event.data.values_at('x', 'y')", 'event.data.dig(:position, "latitude")',
      'event.data[:position]["latitude"]', 'event.data.fetch(:state)["x"]', 'event.data[:locales].first["language_code"]',
      'data = event.data; show.call(Array(data["connectivity"]))', "position = e.data[:position]\nposition.fetch(\"latitude\")"
    ]
    right = [
      "event.data[:connectivity]", "event.data.values_at(:x, :y, :z).map { |axis| axis.to_f }", "event.data.fetch(:state)[:x]",
      'data = event.data; show.call(Array(data[:connectivity]))', 'result["latitude"]', 'page.client_details["route"]',
      "->(data, error) { data[\"latitude\"] }", 'connections.include?("none")'
    ]

    wrong.each { |code| assert_not_empty string_key_reads(code), "not caught: #{code}" }
    right.each { |code| assert_empty string_key_reads(code), "caught by mistake: #{code}" }
  end

  test "these pages read event payloads with Symbol keys" do
    slugs = %w[page-reference events-and-state services-and-plugins reference theming] +
      DocsCatalog.service_catalog.fetch(:services).map { |service| "service-#{service[:helper].tr('_', '-')}" }
    offenders = slugs.flat_map do |slug|
      payload_chunks(page(slug).content).flat_map { |chunk| string_key_reads(chunk) }.map { |line| "#{slug}: #{line}" }
    end
    DocsCatalog::SERVICE_EXAMPLES.each do |helper, code|
      offenders += string_key_reads(code).map { |line| "SERVICE_EXAMPLES #{helper}: #{line}" }
    end

    assert_empty offenders, "Read event payloads with Symbol keys, such as event.data[:state]:\n#{offenders.join("\n")}"
  end

  test "main-only Page, event and service behavior carries the next-release marker" do
    PINNED_MARKERS.each do |slug, phrases|
      content = page(slug).content
      chunks = content.split(/\n(?=- |\n)/).map(&:squish)
      phrases.each do |phrase|
        chunk = chunks.find { |candidate| candidate.include?(phrase) }

        assert chunk, "#{slug} no longer says #{phrase.inspect}"
        assert chunk.include?(MARKER) || under_callout?(content, phrase), "#{slug}: #{phrase.inspect} needs the next-release marker"
      end
    end
    drawers = page("page-reference").content[/^### Drawers and scrolling\n\n(.*?)^### /m, 1]
    assert_includes drawers.to_s, "> #{MARKER}", "page.show_drawer and page.scroll_to need the main client"
  end

  test "named colors on these pages use the client spelling" do
    pattern = /(?:color|bgcolor|color_scheme_seed):\s*:([a-z0-9_]+)/
    wrong = %w[page-reference theming reference].flat_map do |slug|
      page(slug).content.scan(pattern).flatten.select { |name| name.include?("_") }.map { |name| "#{slug} :#{name}" }
    end

    assert_empty wrong, "The clients match named colors without underscores (:deeporange500): #{wrong.join(', ')}"
  end

  private

  # The String-key reads of an event payload in one code block or prose line.
  def string_key_reads(chunk)
    reads = chunk.lines.grep(STRING_KEY_READ).map(&:strip)
    chunk.scan(PAYLOAD_ALIAS).flatten.uniq.each do |name|
      read = /(?<![\w.])#{Regexp.escape(name)}#{PAYLOAD_STEPS}#{STRING_KEY}/
      reads += chunk.lines.grep(read).map(&:strip)
    end
    reads.uniq
  end

  # Code blocks are one chunk each, so a local assigned in one line is
  # followed through the block; prose is checked line by line.
  def payload_chunks(content)
    content.split(/^(```[^\n]*\n.*?^```)$/m).flat_map do |part|
      part.start_with?("```") ? [ part ] : part.lines
    end
  end

  # The fallbacks DocsCatalog.describe writes for a member nobody described.
  def generic_description?(name, description)
    words = name.to_s.delete_prefix("on_").tr("_", " ")
    [ "Sets the #{words} property.", "Fired on #{words}.", "Fired when #{words} occurs." ].include?(description)
  end

  # `name` in code, as `name`, `name(...)`, `name: ...` or `page.name`.
  def named?(content, name)
    content.match?(/`(page\.)?#{Regexp.escape(name)}[`(:= ]/)
  end

  # True when a "> **Requires the next Ruflet release**" callout comes after
  # the last heading before `phrase`, so the callout covers it.
  def under_callout?(content, phrase)
    at = content.index(phrase)
    heading = content.rindex(/^#+ /, at)
    callout = content.rindex("> #{MARKER}", at)
    callout && heading && callout > heading
  end

  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }.then do |entry|
      entry.content ? entry : entry.class.new(**entry.to_h, content: entry.source.read)
    end
  end
end
