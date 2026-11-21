require "test_helper"
require "prism"

# The next-release marker on the dialog, sheet, snack bar, banner, progress,
# list, expansion and table pages, checked sentence by sentence (the marker
# convention is an owner decision):
#
# - a callout under the page H1, or under a heading, covers the whole page or
#   that section;
# - otherwise the inline marker covers the list item it ends or, in a
#   paragraph or curated summary, only the sentence right before it;
# - a code block is covered by a callout, or by a marked sentence or list item
#   right before it.
#
# The tests read the rendered Markdown of each page: the hand-written text, the
# curated example and the generated property, event and method lines.
class DocsNextReleaseProseTest < ActiveSupport::TestCase
  MARKER = DocsCatalog::NEXT_RELEASE_MARKER
  CALLOUT = "> #{MARKER}".freeze
  # The inline marker as a sentence of its own.
  MARKER_SENTENCE = "#{MARKER}.".freeze

  # The pages these tests check. The list may only grow.
  CHECKED_CONTROLS = %w[
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

  # Sentences and list items about main-only behavior. Each must be marked.
  NEXT_RELEASE_SENTENCES = {
    "control-list-tile" => [ "`focus_color` — the background while the row has keyboard focus" ],
    "control-expansion-tile" => [ "With the next release `event.control.expanded` reads the same value" ],
    "control-expansion-panel-list" => [ "With the next release `panel.expanded` reads the same value" ],
    "control-data-table-2" => [
      "The next release also accepts `\"small\"`, `\"medium\"` and `\"large\"`, so `size: :medium` gives an `\"m\"` column",
      "The next release turns the sort arrow in 150 ms by default on every platform",
      "The next release lays out the rows and `empty` on iOS and macOS as Android, web, Windows and Linux do"
    ],
    "control-data-column-2" => [ "The next release also accepts those names, so `size: :medium` gives an `\"m\"` column" ],
    "control-cupertino-list-tile" => [ "`padding` takes effect only with the next release" ],
    "control-cupertino-bottom-sheet" => [ "With 0.0.23 `cupertino_bottom_sheet` raises `ArgumentError` for `dismissible`" ]
  }.freeze

  # Sentences next to those that hold on 0.0.23. Each must stay unmarked.
  RELEASED_SENTENCES = {
    "control-list-tile" => [ "`icon_color`, `text_color`, `selected_color`, `selected_tile_color` and `splash_color`" ],
    "control-expansion-tile" => [
      "Setting `expanded` with `page.update` also opens or closes a tile from code on every platform",
      "`event.control.props[\"expanded\"]` is the new state too"
    ],
    "control-expansion-panel-list" => [
      "the client flips that panel's `expanded`, sends the new value to Ruby",
      "Read the new state from `panel.props[\"expanded\"]`",
      "To open or close a panel from code, set its `expanded` and update the list"
    ],
    "control-data-table-2" => [
      "`size` is `\"s\"` (default), `\"m\"` or `\"l\"`",
      "With 0.0.23 write `size` as `\"s\"`, `\"m\"` or `\"l\"`: the 0.0.23 client draws",
      "`sort_arrow_animation_duration` is in milliseconds.",
      "pass `sort_arrow_animation_duration: 150` to animate it there",
      "except for two 0.0.23 differences",
      "On iOS and macOS its checkboxes are iOS checkboxes.",
      "the rows sit in the middle of the space under the heading"
    ],
    "control-data-column-2" => [ "With 0.0.23 the client draws `\"small\"`, `\"medium\"` and `\"large\"`, which `size: :medium` sends, as `\"s\"` columns." ],
    "control-cupertino-list-tile" => [ "With 0.0.23 pad a row with `list_tile(content_padding: 16)`." ],
    "control-cupertino-bottom-sheet" => [ "build it with `bottom_sheet(..., dismissible: false)`" ]
  }.freeze

  Unit = Struct.new(:text, :marked, :code, keyword_init: true)

  test "sentences about main-only behavior carry the marker" do
    NEXT_RELEASE_SENTENCES.each do |slug, phrases|
      phrases.each do |phrase|
        assert unit_with(slug, phrase).marked, "#{slug}: put the next-release marker right after #{phrase.inspect}"
      end
    end
  end

  test "sentences that hold on 0.0.23 stay unmarked" do
    RELEASED_SENTENCES.each do |slug, phrases|
      phrases.each do |phrase|
        refute unit_with(slug, phrase).marked, "#{slug}: #{phrase.inspect} works on 0.0.23, so no next-release marker may cover it"
      end
    end
  end

  # An inline marker that starts its paragraph follows no sentence, so it
  # marks nothing.
  test "every inline marker follows the text it marks" do
    orphans = CHECKED_CONTROLS.flat_map { |slug| page_units(slug).fetch(:orphans).map { |text| "#{slug}: #{text.truncate(160)}" } }

    assert_empty orphans, "Put these markers right after the sentence they mark, or make them a callout under a heading:\n#{orphans.join("\n")}"
  end

  # config/next_release.json "members" lists the keywords, events and methods
  # 0.0.23 Ruby rejects (ArgumentError or NoMethodError). A sentence that names
  # one of its page's members, or passes a member to its control's helper,
  # must be marked. A sentence that passes the keyword to another helper, as in
  # `bottom_sheet(..., dismissible: false)` on the CupertinoBottomSheet page, is
  # about that helper.
  test "checked pages mark every sentence that names a keyword 0.0.23 rejects" do
    unmarked = CHECKED_CONTROLS.flat_map do |slug|
      units(slug).reject { |unit| unit.marked || unit.code }.flat_map do |unit|
        sentences(unit.text).filter_map do |sentence|
          rejected = rejected_names(slug, sentence)
          "#{slug} (#{rejected.join(', ')}): #{sentence.truncate(160)}" if rejected.any?
        end
      end
    end

    assert_empty unmarked, "Mark these sentences, which name keywords 0.0.23 rejects:\n#{unmarked.join("\n")}"
  end

  test "Ruby code on checked pages passes keywords 0.0.23 rejects only under a marker" do
    unmarked = CHECKED_CONTROLS.flat_map do |slug|
      units(slug).select { |unit| unit.code && !unit.marked && unit.text.start_with?("```ruby") }.flat_map do |unit|
        rejected_calls(unit.text.lines[1..-2].join).map { |call| "#{slug}: #{call}" }
      end
    end

    assert_empty unmarked, "Put a marked sentence right before these blocks, or drop the keyword:\n#{unmarked.join("\n")}"
  end

  test "the checks see planted mistakes" do
    summary = "Keep it open with `cupertino_bottom_sheet(content, dismissible: false)`. It sends a `BottomSheet`. With 0.0.23 it raises. #{MARKER_SENTENCE}"
    planted = prose_units("# CupertinoBottomSheet\n\n#{summary}\n")

    assert_equal [ "dismissible" ], rejected_names("control-cupertino-bottom-sheet", planted.first.text)
    refute planted.first.marked
    assert planted.last.marked
    assert_empty rejected_names("control-cupertino-bottom-sheet", "Build it with `bottom_sheet(..., dismissible: false)`, and `dismissible` wins.")
    assert_equal [ "dismissible" ], rejected_names("control-cupertino-bottom-sheet", "On iOS and macOS `dismissible` wins when both are set.")
    assert_equal [ "cupertino_bottom_sheet(dismissible:)" ], rejected_calls("page.add(cupertino_bottom_sheet(text(\"A\"), dismissible: false))")
    assert_empty rejected_calls("page.add(bottom_sheet(text(\"A\"), dismissible: false))")

    orphans = []
    code = "```ruby\npage.add(text(\"A\"))\n```"
    blocks = prose_units("# T\n\n#{MARKER_SENTENCE}\n\nWith main it works. #{MARKER_SENTENCE}\n\n#{code}\n\nIt works.\n\n#{code}\n", orphans)
    assert_equal 1, orphans.size
    assert_equal [ true, false ], blocks.select(&:code).map(&:marked)
  end

  private

  def unit_with(slug, phrase)
    matches = units(slug).select { |unit| !unit.code && unit.text.include?(phrase) }

    assert_equal 1, matches.size, "#{slug} should say #{phrase.inspect} in one sentence or list item"
    matches.first
  end

  def units(slug)
    page_units(slug).fetch(:units)
  end

  # The page's units: the prose above the generated API (a prose page's
  # Complete API appendix, or a generated page's Properties list) and the
  # generated "- `name` ..." lines, each with whether a marker covers it.
  def page_units(slug)
    @page_units ||= {}
    @page_units[slug] ||= begin
      content = page(slug).content
      prose, api = content.include?("\n## Complete API\n") ? content.split("\n## Complete API\n", 2) : content.split(/^## Properties$/, 2)
      orphans = []
      units = prose_units(prose, orphans)
      page_covered = prose.split(/^## /).first.sub(/\A# .*\n+/, "").start_with?(CALLOUT)
      api_lines = api.to_s.lines.map(&:strip).select { |line| line.start_with?("- ") }
      units += api_lines.map { |line| Unit.new(text: line, marked: page_covered || line.include?(MARKER), code: false) }
      { units: units, orphans: orphans }
    end
  end

  # Splits Markdown prose into list items, sentences and fenced code blocks.
  def prose_units(prose, orphans = [])
    units = []
    page_covered = false
    covered_level = nil
    heading_level = nil
    last_marked = false

    prose.split(/^(```[^\n]*\n.*?^```)[ \t]*$/m).each_with_index do |part, index|
      if index.odd?
        units << Unit.new(text: part, marked: page_covered || !covered_level.nil? || last_marked, code: true)
        next
      end

      part.split(/\n[ \t]*\n/).map(&:strip).reject(&:empty?).each do |block|
        if (hashes = block[/\A(#+) /, 1])
          covered_level = nil if covered_level && hashes.size <= covered_level
          heading_level = hashes.size
          last_marked = false
          next
        end
        if block.start_with?(">")
          if heading_level && block.start_with?(CALLOUT)
            heading_level == 1 ? page_covered = true : covered_level = heading_level
          end
          heading_level = nil
          next
        end
        heading_level = nil
        covered = page_covered || !covered_level.nil?

        block.split(/\n(?=- )/).map(&:squish).each do |chunk|
          if chunk.start_with?("- ")
            last_marked = covered || chunk.include?(MARKER)
            units << Unit.new(text: chunk, marked: last_marked, code: false)
            next
          end

          parts = sentences(chunk)
          orphans << chunk if parts.first == MARKER_SENTENCE
          parts.each_with_index do |sentence, position|
            next if sentence == MARKER_SENTENCE

            units << Unit.new(text: sentence, marked: covered || parts[position + 1] == MARKER_SENTENCE || sentence.include?(MARKER), code: false)
          end
          last_marked = covered || parts.last == MARKER_SENTENCE
        end
      end
    end
    units
  end

  # Sentences end at ".", "!" or "?" followed by a space, outside code spans.
  def sentences(text)
    spans = []
    masked = text.gsub(/`[^`]*`/) { |span| spans << span; "\u0000#{spans.size - 1}\u0001" }
    masked.split(/(?<=[.!?])\s+/).map { |sentence| sentence.gsub(/\u0000(\d+)\u0001/) { spans[Regexp.last_match(1).to_i] } }
  end

  # The members a sentence names: its own page's members named in a code span
  # (`name`, `name:` or `name(...)`) unless the sentence passes that keyword to
  # another helper, and the members any helper call in a code span passes to
  # that helper's own control.
  def rejected_names(slug, sentence)
    spans = sentence.scan(/`([^`]+)`/).flatten
    calls = spans.filter_map { |span| span_call(span) }
    own_helpers = helpers_of(slug)

    bare = member_names(members(slug).values).select do |name|
      named = spans.any? { |code| code == name || code.match?(/\A#{Regexp.escape(name)}[(:]/) }
      named && calls.none? { |helper, keywords| !own_helpers.include?(helper) && keywords.include?(name) }
    end
    passed = calls.flat_map { |helper, keywords| keywords & keyword_members(helper_slugs[helper]) }
    (bare + passed).uniq
  end

  # "helper(a: 1, b: 2)" in a code span => ["helper", ["a", "b"]].
  def span_call(span)
    helper, args = span.match(/\A([a-z_][a-z_0-9]*)\((.*)\)\z/m)&.captures
    [ helper, args.scan(/(?<![\w:])([a-z_][a-z_0-9]*):(?=\s)/).flatten ] if helper
  end

  # "helper(keyword:)" for each call in the code that passes a member keyword
  # to a control helper.
  def rejected_calls(code)
    found = []
    visit = lambda do |node|
      if node.is_a?(Prism::CallNode) && (slug = helper_slugs[node.name.to_s])
        keywords = Array(node.arguments&.arguments).grep(Prism::KeywordHashNode).flat_map(&:elements)
          .filter_map { |element| element.key.unescaped if element.is_a?(Prism::AssocNode) && element.key.is_a?(Prism::SymbolNode) }
        (keywords & keyword_members(slug)).each { |keyword| found << "#{node.name}(#{keyword}:)" }
      end
      node.compact_child_nodes.each { |child| visit.call(child) }
    end
    visit.call(Prism.parse(code).value)
    found
  end

  def members(slug)
    @members ||= JSON.parse(Rails.root.join("config/next_release.json").read).fetch("members")
    @members.fetch(slug.to_s, {})
  end

  def keyword_members(slug)
    member_names(members(slug).values_at("properties", "events").compact)
  end

  # A kind lists its names as an array, or as a hash of name => note.
  def member_names(lists)
    lists.flat_map { |names| names.is_a?(Hash) ? names.keys : names }
  end

  def helper_slugs
    @helper_slugs ||= DocsCatalog.control_catalog.each_with_object({}) do |control, map|
      Array(control[:helpers]).each { |helper| map[helper.to_s] ||= control[:slug] }
    end
  end

  def helpers_of(slug)
    helper_slugs.select { |_helper, helper_slug| helper_slug == slug }.keys
  end

  # DocsCatalog.find falls back to the first page for an unknown slug.
  def page(slug)
    DocsCatalog.find(slug).tap { |entry| assert_equal slug, entry.slug, "DocsCatalog has no #{slug} page" }
  end
end
