require "test_helper"

class DocsGeneratedExamplesTest < ActiveSupport::TestCase
  BUTTON_WIDGET_TYPES = %w[
    cupertinobutton cupertinofilledbutton cupertinotintedbutton button
    filledbutton fillediconbutton filledtonalbutton filledtonaliconbutton
    floatingactionbutton iconbutton outlinedbutton outlinediconbutton textbutton
  ].freeze

  test "generated examples do not mix url navigation with click handlers" do
    bad_examples = []

    DocsCatalog.all_entries.each do |entry|
      next unless entry.content

      entry.content.scan(/```ruby\n(.*?)```/m).flatten.each_with_index do |block, index|
        next unless block.include?("url:") && block.include?("on_click:")

        bad_examples << "#{entry.slug} block #{index + 1}"
      end
    end

    assert_empty bad_examples, "Use either `url:` or `on_click:` in generated examples, not both:\n#{bad_examples.join("\n")}"
  end

  test "button docs expose url as a public property" do
    button_entries = DocsCatalog.control_catalog.select { |entry| BUTTON_WIDGET_TYPES.include?(entry[:widget_type]) }
    entries_without_url = button_entries.reject { |entry| Array(entry[:properties]).include?(:url) || Array(entry[:properties]).include?("url") }

    assert_empty entries_without_url.map { |entry| entry[:slug] }
  end

  test "app bar docs attach the bar to the page instead of a view" do
    content = DocsCatalog.find("control-app-bar").content

    assert_includes content, "page.appbar = app_bar("
    assert_includes content, "page.add("
    refute_match(/view\(\s*appbar:/m, content)
  end
end
