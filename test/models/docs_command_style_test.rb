require "test_helper"

class DocsCommandStyleTest < ActiveSupport::TestCase
  test "user-facing Markdown never requires bundle exec" do
    bad_lines = []

    paths = Rails.root.glob("app/content/docs/**/*.md")
    paths << Rails.root.join("README.md") if Rails.root.join("README.md").exist?

    paths.each do |path|
      path.read.each_line.with_index(1) do |line, line_number|
        next unless line.match?(/\bbundle\s+exec\b/)

        bad_lines << "#{path.relative_path_from(Rails.root)}:#{line_number}: #{line.strip}"
      end
    end

    assert_empty bad_lines, "Use direct executables in user-facing docs:\n#{bad_lines.join("\n")}"
  end
end
