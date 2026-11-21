require "test_helper"
require "open3"

# An event description that names `event.<reader>` promises that a handler can
# call it. Ruflet::Event answers its own readers (data, control, page, value
# ...) and, through method_missing, the readers of the typed event Ruflet
# builds for the event's name (GestureEventFactory::EVENT_CLASS_MAP). Any other
# reader raises NoMethodError inside the handler: window_drag_area's
# "drag_start" has no typed event, so `event.local_position` failed there.
class DocsEventReadersTest < ActiveSupport::TestCase
  # Prints the readers of Ruflet::Event and of each typed event of one
  # ruflet_core lib directory. It runs in its own process, so the app's own
  # Ruflet gems are not redefined.
  DUMP_READERS = <<~'RUBY'.freeze
    require "json"
    require File.join(ARGV.fetch(0), "ruflet_ui/ruflet/event")
    plain = Object.public_instance_methods
    own = Ruflet::Event.public_instance_methods - plain - %i[method_missing respond_to_missing?]
    typed = Ruflet::Events::GestureEventFactory::EVENT_CLASS_MAP.transform_values { |klass| klass.public_instance_methods - plain }
    puts JSON.generate("event" => own, "typed" => typed)
  RUBY

  test "event readers the descriptions name exist on the published release" do
    config = next_release_config
    spec = Gem::Specification.find_by_name("ruflet_core")

    assert_equal config.fetch("released"), spec.version.to_s, "Gemfile.lock should pin the published ruflet_core"

    offenses = reader_offenses(readers(Pathname.new(spec.full_gem_path).join("lib")), skip_marked: true)

    assert_empty offenses, <<~MESSAGE
      With ruflet_core #{spec.version}, these events have no such reader, so the handler raises NoMethodError.
      Describe the payload as `event.data[:key]`, or mark a line that needs the next release:
      #{offenses.join("\n")}
    MESSAGE
  end

  test "event readers the descriptions name exist on Ruflet main" do
    root = ENV["RUFLET_SOURCE_ROOT"].to_s.strip
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout to check the event readers against it" if root.empty?

    offenses = reader_offenses(readers(Pathname.new(root).join("packages/ruflet_core/lib")))

    assert_empty offenses, <<~MESSAGE
      With the Ruflet source at #{root}, these events have no such reader, so the handler raises NoMethodError.
      Describe the payload as `event.data[:key]` instead:
      #{offenses.join("\n")}
    MESSAGE
  end

  test "the reader check catches a reader the event does not have" do
    tree = readers(Pathname.new(Gem::Specification.find_by_name("ruflet_core").full_gem_path).join("lib"))
    planted = { "events" => {}, "widget_overrides" => { "windowdragarea" => {
      "on_drag_start" => "`event.local_position` gives the point.",
      "on_drag_end" => "`event.data[:v]` is the velocity."
    } } }

    assert_includes tree.fetch("typed").fetch("pan_start"), "local_position"
    assert_equal [ "widget_overrides.windowdragarea.on_drag_start: event.local_position" ], reader_offenses(tree, descriptions: planted)
  end

  private

  def readers(lib)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", DUMP_READERS, lib.to_s)

    assert status.success?, "Could not load Ruflet's events from #{lib}:\n#{stderr}"
    JSON.parse(stdout)
  end

  # "<description>: event.<reader>" for each reader a description names that
  # its event does not have. With skip_marked, descriptions whose every line
  # carries the next-release marker are left out.
  def reader_offenses(tree, descriptions: property_descriptions, skip_marked: false)
    described_events(descriptions).flat_map do |key, controls, name, text|
      next [] if skip_marked && marked?(controls, name, text)

      known = tree.fetch("event") + tree.fetch("typed").fetch(name.delete_prefix("on_"), [])
      text.scan(/\bevent\.([a-z_]\w*[?!]?)/).flatten.uniq.reject { |reader| known.include?(reader) }.map { |reader| "#{key}: event.#{reader}" }
    end
  end

  # [key, the controls whose page renders the text, event name, text] for each
  # shared event description and each on_* widget override.
  def described_events(descriptions)
    overrides = descriptions.fetch("widget_overrides")
    shared = descriptions.fetch("events").map do |name, text|
      controls = controls_with_event(name).reject { |control| overrides.dig(control[:widget_type].to_s, name) }
      [ "events.#{name}", controls, name, text ]
    end
    shared + overrides.flat_map do |widget, names|
      names.select { |name, _text| name.start_with?("on_") }.map do |name, text|
        [ "widget_overrides.#{widget}.#{name}", controls_with_event(name).select { |control| control[:widget_type].to_s == widget }, name, text ]
      end
    end
  end

  def controls_with_event(name)
    control_catalog.select { |control| Array(control[:events]).map(&:to_s).include?(name) }
  end

  def marked?(controls, name, text)
    return true if text.include?(DocsCatalog::NEXT_RELEASE_MARKER)
    return false if controls.empty?

    controls.all? { |control| next_release_pages.include?(control[:slug]) || next_release_events.include?([ control[:slug], name ]) }
  end

  def next_release_config
    @next_release_config ||= JSON.parse(Rails.root.join("config/next_release.json").read)
  end

  def next_release_pages
    next_release_config.fetch("controls")
  end

  # [slug, event] for each event line config/next_release.json marks.
  def next_release_events
    @next_release_events ||= begin
      lists = [ next_release_config.fetch("members"), next_release_config.fetch("client_ignored"), *next_release_config.fetch("design_client_ignored").values ]
      lists.flat_map do |controls|
        controls.flat_map do |slug, kinds|
          names = kinds.fetch("events", [])
          (names.is_a?(Hash) ? names.keys : names).map { |name| [ slug, name ] }
        end
      end
    end
  end

  def property_descriptions
    @property_descriptions ||= JSON.parse(Rails.root.join("config/property_descriptions.json").read)
  end

  def control_catalog
    @control_catalog ||= DocsCatalog.control_catalog
  end
end
