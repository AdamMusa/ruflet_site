require "test_helper"

class DocsColorValuesTest < ActiveSupport::TestCase
  COLOR_PROPERTIES = %w[
    color bgcolor border_color fill_color base_color highlight_color shadow_color
    icon_color focus_color hover_color splash_color splash_dark_color
    icon_background theme_color
  ].freeze

  test "docs use symbols for named colors and strings only for hex values" do
    pattern = /(?:#{COLOR_PROPERTIES.join('|')}):\s*"([^"]+)"/
    bad_values = []

    Rails.root.glob("app/content/docs/**/*.md").each do |path|
      path.read.scan(pattern) do |(value)|
        next if value.match?(/\A(?:#|0x)[0-9a-fA-F]{6,8}(?:,\d+(?:\.\d+)?)?\z/)

        bad_values << "#{path.relative_path_from(Rails.root)} uses quoted named color #{value.inspect}"
      end
    end

    assert_empty bad_values, "Use symbols like :deep_orange_500 for named colors:\n#{bad_values.join("\n")}"
  end
end
