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

  # page.screen_brightness's proxy setters send {"value" => ...} and work; the
  # service object's send {"brightness" => ...} and fail (page.rb and
  # current_service_methods.rb, the same in 0.0.23).
  test "the proxy section names the proxy methods that differ from the service methods" do
    descriptions = JSON.parse(Rails.root.join("config/property_descriptions.json").read).fetch("services")
    wrong = DocsCatalog.service_catalog.fetch(:services).filter_map do |service|
      differing = descriptions.dig(service[:helper], "proxy_methods").to_h.keys
      next if differing.empty?

      slug = "service-#{service[:helper].tr('_', '-')}"
      intro = page(slug).content[/^## Page proxy methods\n\n(.*?)\n\n/m, 1].to_s
      unnamed = differing.reject { |name| intro.include?("`#{name}`") }
      "#{slug}: #{intro}" if intro.include?("They work like the service methods") || unnamed.any?
    end

    assert_empty wrong, "Say which proxy methods do not work like the service methods:\n#{wrong.join("\n")}"
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

  test "the events page names every Ruflet::Event reader and method" do
    content = page("events-and-state").content
    names = DocsCatalog.runtime_catalog.fetch(:event).map { |method| method[:name].to_s } - %w[initialize method_missing]
    missing = names.reject { |name| code_named?(content, name) }

    assert_empty missing, "events_and_state.md does not describe these Ruflet::Event methods: #{missing.join(', ')}"
  end

  test "the docs name every Ruflet entry point, DSL app method and DSL helper" do
    reference = page("reference").content
    every_page = Rails.root.glob("app/content/docs/*.md").map(&:read).join("\n")
    catalog = DocsCatalog.runtime_catalog
    names = ->(key) { catalog.fetch(key).map { |method| method[:name].to_s } }
    missing = (names.(:dsl_app) - %w[initialize]).reject { |name| code_named?(reference, name) }.map { |name| "DSL app #{name}" }
    missing += names.(:ruflet).reject { |name| code_named?(every_page, name) }.map { |name| "Ruflet.#{name}" }
    missing += names.(:dsl_utilities).reject { |name| code_named?(every_page, name) }.map { |name| "DSL #{name}" }

    assert_empty missing, "Document these in reference.md (or the page for their controls): #{missing.join(', ')}"
  end

  # The DSL helpers the reference describes itself. The others (paint and
  # the path_* helpers, local_auth, qrcode_scanner) belong to the pages of
  # their controls and services. Ruflet.client_action is on the services page.
  REFERENCE_DSL_HELPERS = %w[
    animation animation_style app base_page basepage control default_host default_port dialogs duration
    duration_in_milliseconds map_layer maplayer page pagelet service service_registry serviceregistry widget window
  ].freeze

  # A name used elsewhere (page.window, the Page's `window` keyword,
  # `typed_data` in prose) must not count as the entry that documents it.
  test "the reference and the events page give each entry point, helper and Event reader its own entry" do
    catalog = DocsCatalog.runtime_catalog
    names = ->(key) { catalog.fetch(key).map { |method| method[:name].to_s } }
    reference = page("reference").content
    dsl = reference[/^## DSL entry points\n(.*?)^## /m, 1].to_s
    events = page("events-and-state").content

    assert_empty REFERENCE_DSL_HELPERS - names.(:dsl_utilities), "REFERENCE_DSL_HELPERS lists names the catalog does not"
    missing = REFERENCE_DSL_HELPERS.reject do |name|
      escaped = Regexp.escape(name)
      dsl.match?(/`(?:Ruflet(?:::DSL)?\.)?#{escaped}\(|`Ruflet::DSL\.#{escaped}`| \/ `#{escaped}`/)
    end.map { |name| "DSL #{name}" }
    missing += (names.(:ruflet) - %w[client_action]).reject do |name|
      reference.match?(/^- `Ruflet\.#{Regexp.escape(name)}[`( ]/)
    end.map { |name| "Ruflet.#{name}" }
    missing += (names.(:event) - %w[initialize method_missing]).reject do |name|
      events.match?(/^- `(?:event\.)?#{Regexp.escape(name)}[`( ]/)
    end.map { |name| "Event##{name}" }

    assert_empty missing, "Give these a list entry (or a call) of their own: #{missing.join(', ')}"
  end

  # Ruflet::UI::Types holds these constants, the same objects as
  # Ruflet::<name> (identical in 0.0.23 and on main). MainAxisAlignment,
  # CrossAxisAlignment and TextAlign are not among them.
  UI_TYPES = %w[Duration Offset StrutStyle TextBaseline TextDecoration TextDecorationStyle TextOverflow TextStyle TextThemeStyle].freeze

  test "the reference names only the constants that Ruflet::UI::Types holds" do
    catalog = DocsCatalog.runtime_catalog.fetch(:constant_modules).map { |mod| mod[:name] }
    paragraph = page("reference").content.split(/\n{2,}/).find { |chunk| chunk.include?("`Ruflet::UI::Types` is") }

    assert_empty catalog.grep(/\ARuflet::UI::Types::/).map { |name| name.split("::").last } - UI_TYPES
    assert paragraph, "reference.md no longer says which constants Ruflet::UI::Types holds"
    paragraph.squish.split(/(?<=\.)\s+/).each do |sentence|
      named = sentence.scan(/`(?:Ruflet::(?:UI::Types::)?)?([A-Z]\w+)`/).flatten
      if sentence.include?("only under")
        assert_empty named & UI_TYPES, "Ruflet::UI::Types holds these: #{sentence}"
      else
        assert_empty named - UI_TYPES, "Ruflet::UI::Types does not hold these: #{sentence}"
      end
    end
    assert_empty page("reference").content.scan(/Ruflet::UI::Types::(\w+)/).flatten - UI_TYPES
  end

  # Claims that reviews corrected, checked against the Ruby source, the
  # engine and the template 0.0.23 builds with: the page, a phrase that finds
  # the paragraph or list item, what it must say and what it must not say.
  CORRECTED_CLAIMS = [
    # ruflet_backend.dart updatePageSize sends {"type": "resized"} on desktop;
    # services/window.dart onWindowEvent drops window_manager's "resize",
    # "resized" and "move". window_manager emits "close" and then closes the
    # window unless prevent_close is set, and the client forwards an event
    # only after an asynchronous getWindowState(), so the page promises
    # "close" only with prevent_close: true.
    [ "page-reference", "`page.window.on(:event)", [ '`"resized"`', '`"close"` (only with `prevent_close: true`)' ],
      [ "no window event", '`"resize"`', '`"move"`' ] ],
    # ruflet_backend.dart _registerClient: these flags, and no client_ip,
    # client_user_agent or sess.
    [ "page-reference", "When it connects, the client also sends", [ "`client_ip`, `client_user_agent` and `sess` are Page keywords that no Ruflet client sends" ],
      [ /client also sends[^.]*`(?:client_ip|client_user_agent|sess)`/ ] ],
    # 0.0.23 parses typed text; a text field keeps "null" and a JSON object in props.
    [ "events-and-state", "- `data` — the client's payload", [ 'typed `"123"` arrives as `123` in `event.data`', 'keeps `"null"` and a JSON object' ],
      [ /arrives as `"123"`/, 'in `event.data` and in `event.control.props["value"]`, `"2.50"`' ] ],
    # ruflet_core.rb resolved_run_port: "abc".to_i is 0, and a negative or
    # blank value falls back to 8550.
    [ "reference", "- `Ruflet.resolved_run_port(port)`", [ "gives 0", "A negative or blank value gives 8550" ], [ /negative value gives 0/ ] ],
    # dsl.rb default_port parses RUFLET_PORT the same way, so RUFLET_PORT=abc
    # gives 0, not 8550.
    [ "reference", "- `Ruflet.app(host: nil, port: nil)", [ "read as `Ruflet.resolved_run_port` reads it" ], [ /8550 when it is not a number/ ] ],
    # dsl.rb read_duration_part: numbers, Floats included, count.
    [ "reference", "- `duration(days:", [ "`duration(seconds: 1.5)` is `1500`" ], [ "A numeric String such as `\"2\"` counts" ] ],
    # The 0.0.23 client ignores font_family_fallback: not in the unmarked key list.
    [ "theming", "A text style, in `text_theme`", [ "`font_family`" ], [ "font_family_fallback" ] ],
    # geolocator.dart restarts a failed stream on the next patch, not by
    # itself. The template's (0.0.23) init and update both start a stream,
    # whether or not on_position_change is set.
    [ "service-geolocator", "- `configuration` —",
      [ "at the next update of the service", "The 0.0.23 client streams positions from the moment the service is added, even without `on_position_change`" ],
      [ "or after the stream failed", /0\.0\.23 client streams positions only while/ ] ]
  ].freeze

  test "the claims that reviews corrected stay corrected" do
    CORRECTED_CLAIMS.each do |slug, phrase, wanted, unwanted|
      chunk = page(slug).content.split(/\n(?=- |\n)/).map(&:squish).find { |candidate| candidate.include?(phrase) }

      assert chunk, "#{slug} no longer says #{phrase.inspect}"
      wanted.each { |text| assert_includes chunk, text, "#{slug}: #{phrase.inspect} must say #{text.inspect}" }
      unwanted.each do |text|
        assert_not(text.is_a?(Regexp) ? chunk.match?(text) : chunk.include?(text), "#{slug}: #{phrase.inspect} must not say #{text.inspect}")
      end
    end
    # url_launcher's on_result does not report whether the URL opened.
    launch = DocsCatalog::SERVICE_EXAMPLES.fetch("url_launcher")
    assert_includes launch, "Asked the browser to open"
    assert_no_match(/"Opened\b/, launch)
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
      "are View keywords on `main` only", "treats the `show_*_icon` flags as booleans", "`show_drawer` / `close_drawer`"
    ],
    "events-and-state" => [
      "`ActionResultEvent`", "`PasteFilesEvent`", "`ViewsPopUntilEvent`", "`event.with_name(name)`",
      "`event.control.value` raises NoMethodError", "`page.pop_views_until(route, result: nil)` pops",
      "Any `page.on_<event> =` writer registers", "`event.relayed(name:, target:, control:)`",
      "On `main`, what the user typed or picked stays a String"
    ],
    # The client actions, device information and local authentication
    # sections carry markers too.
    "services-and-plugins" => [
      "`local_authentication.authenticate` waits 60 seconds", "On 0.0.23 `Ruflet.client_action` does not exist",
      "On 0.0.23 these page methods do nothing", "`local_authentication` — properties `data` and `key`",
      "On 0.0.23 `page.local_auth` and `page.local_authentication` raise NoMethodError"
    ],
    "theming" => [ "A style also takes `font_family_fallback`" ],
    "reference" => [ "also ignores `font_family_fallback:`", "builds the value of an `animation_style:` property" ],
    "service-audio-recorder" => [ "such a name, or none, arrives as the error", "`device` also takes the id alone" ],
    "service-secure-storage" => [ "On `main` a change takes effect at the next call" ],
    "service-geolocator" => [ "on `main` it receives the error too", "On `main` it streams only while `on_position_change` is set" ],
    # config/next_release.json "services" puts this callout under the H1.
    "service-local-authentication" => [ "On 0.0.23 `page.local_authentication` raises NoMethodError" ]
  }.freeze

  # The server symbolizes the keys of an event's Hash payload, nested Hashes
  # included, so a String key is always nil in a real app: event.data["state"],
  # values_at("x"), event.data[:position]["latitude"],
  # event.data.fetch(:state)["x"], or data = event.data; data["state"].
  # event.raw_data holds the same Hash, and to_h, slice and except keep its
  # Symbol keys. Symbol, Integer and method steps (event.data[:locales].first)
  # may come before the String key.
  PAYLOAD_STEPS = /(?:\[[^\]"']*\]|&?\.(?:fetch|dig)\([^)"']*\)|&?\.(?:first|last|to_h|to_hash)\b)*/
  STRING_KEY = /(?:&?\[\s*["']|&?\.(?:values_at|dig|fetch|fetch_values|key\?|has_key\?|slice|except)\(\s*["']|&?\.(?:values_at|dig|fetch_values|slice|except)\([^)]*["'])/
  STRING_KEY_READ = /\.(?:raw_)?data#{PAYLOAD_STEPS}#{STRING_KEY}/
  # A local that holds the payload or part of it: data = event.data[:position]
  PAYLOAD_ALIAS = /(?<![\w.])([a-z_]\w*)\s*=(?![=~>])\s*[a-z_]\w*\.(?:raw_)?data\b#{PAYLOAD_STEPS}\s*(?:$|[;)}|]|\|\||or\b|&&)/

  test "the String-key check catches direct, chained and aliased reads" do
    wrong = [
      'event.data["connectivity"]', "event.data.values_at('x', 'y')", 'event.data.dig(:position, "latitude")',
      'event.data[:position]["latitude"]', 'event.data.fetch(:state)["x"]', 'event.data[:locales].first["language_code"]',
      'data = event.data; show.call(Array(data["connectivity"]))', "position = e.data[:position]\nposition.fetch(\"latitude\")",
      'event.raw_data["state"]', 'event.data.to_h["state"]', 'event.data.slice("type").values.first', 'event.data.except(:x, "type")',
      "payload = event.raw_data\npayload[\"type\"]"
    ]
    right = [
      "event.data[:connectivity]", "event.data.values_at(:x, :y, :z).map { |axis| axis.to_f }", "event.data.fetch(:state)[:x]",
      "data = event.data; show.call(Array(data[:connectivity]))", 'result["latitude"]', 'page.client_details["route"]',
      "->(data, error) { data[\"latitude\"] }", 'connections.include?("none")', 'event.data.transform_keys(&:to_s)["state"]',
      "event.data.slice(:type, :x)", 'event.raw_data.to_s.include?("1")'
    ]

    wrong.each { |code| assert_not_empty string_key_reads(code), "not caught: #{code}" }
    right.each { |code| assert_empty string_key_reads(code), "caught by mistake: #{code}" }
  end

  test "these pages read event payloads with Symbol keys" do
    offenders = reference_slugs.flat_map do |slug|
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

  # On every page reference_slugs lists, the generated service pages
  # included, a marker must cover a sentence PINNED_MARKERS lists for that
  # page; a page with no entry may carry none.
  test "the next-release marker appears only where PINNED_MARKERS pins it" do
    stray = reference_slugs.flat_map do |slug|
      content = page(slug).content
      pins = PINNED_MARKERS.fetch(slug, [])
      content.split(/\n(?=- |\n)/).select { |chunk| chunk.include?(MARKER) }.filter_map do |chunk|
        scope = chunk.lstrip.start_with?("> ") ? section_around(content, chunk) : chunk
        "#{slug}: #{chunk.squish[0, 120]}" unless pins.any? { |phrase| scope.squish.include?(phrase) }
      end
    end

    assert_empty stray, "These markers cover nothing PINNED_MARKERS lists, so they may mark what works on 0.0.23:\n#{stray.join("\n")}"
  end

  # A Material color or theme role written with the underscores of its
  # Ruflet::Colors constant: :deep_orange_500, "blue_grey", :on_primary.
  UNDERSCORED_COLOR = /\A(?:
    (?:deep_|light_|blue_)?(?:red|pink|purple|indigo|blue|cyan|teal|green|lime|yellow|amber|orange|brown|grey)(?:_?accent)?(?:_?\d+)? |
    (?:white|black)_?\d+ |
    (?:on_)?(?:inverse_)?(?:primary|secondary|tertiary|error|surface|outline)(?:_(?:container|variant|fixed|dim|bright|tint|lowest|low|highest|high))*
  )\z/x

  test "named colors on these pages use the client spelling" do
    pattern = /(?:color|bgcolor|color_scheme_seed):\s*:([a-z0-9_]+)/
    wrong = %w[page-reference theming reference].flat_map do |slug|
      page(slug).content.scan(pattern).flatten.select { |name| name.include?("_") }.map { |name| "#{slug} :#{name}" }
    end
    code = reference_slugs.to_h { |slug| [ slug, page(slug).content.scan(/^```ruby\n(.*?)^```/m).flatten.join("\n") ] }
    code["SERVICE_EXAMPLES"] = DocsCatalog::SERVICE_EXAMPLES.values.join("\n")
    code.each do |where, source|
      names = source.scan(/(?<![:\w]):([a-z][a-z0-9_]*)\b/).flatten + source.scan(/(?:[\w\]]:|=>)\s*"([a-z][a-z0-9_]*)"/).flatten
      wrong += names.select { |name| name.include?("_") && name.match?(UNDERSCORED_COLOR) }.map { |name| "#{where} #{name}" }
    end

    assert_empty wrong.uniq, "The clients match named colors without underscores (:deeporange500): #{wrong.uniq.join(', ')}"
  end

  private

  # The hand-written pages this reference covers and every generated service page.
  def reference_slugs
    %w[page-reference events-and-state services-and-plugins reference theming] +
      DocsCatalog.service_catalog.fetch(:services).map { |service| "service-#{service[:helper].tr('_', '-')}" }
  end

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

  # A method in code, with or without a receiver: `name`, `name(...)`,
  # `event.name`, `Ruflet.name(...)` or `Ruflet::DSL.name`.
  def code_named?(content, name)
    content.match?(/`(?:[\w:]+\.)?#{Regexp.escape(name)}[`( ]/)
  end

  # The text from the heading before +chunk+ to the next heading.
  def section_around(content, chunk)
    at = content.index(chunk)
    start = content.rindex(/^#+ /, at) || 0
    finish = content.index(/^#+ /, at + chunk.length) || content.length
    content[start...finish]
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
