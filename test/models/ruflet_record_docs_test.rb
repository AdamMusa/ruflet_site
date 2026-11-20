require "test_helper"
require "open3"

class RufletRecordDocsTest < ActiveSupport::TestCase
  MARKER = "**Requires the next Ruflet release** (on `main`, not in 0.0.23)".freeze

  def page = DocsCatalog.find("ruflet-record")

  test "the RufletRecord page is listed under Integrations" do
    assert_equal "ruflet-record", page.slug
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }
    assert_includes integrations.entries.map(&:slug), "ruflet-record"
  end

  test "only the main-only parts of the page carry the next-release marker" do
    content = page.source.read
    range = content[/^A range with an open end.*?(?=\n\n)/m]

    assert range, "Missing the open-ended range paragraph"
    assert_includes range, MARKER
    assert_includes content[/^### Self-contained builds\n\n.*?\n/m].to_s, "> #{MARKER}"
    # The rest of the page is the published 0.0.23 gem.
    assert_equal 2, content.scan(MARKER).size
    refute_includes content[/\A.*?(?=^## Queries)/m], MARKER
  end

  # Runs the page's Ruby examples in order, as one program, against the
  # ruflet_record in RUFLET_SOURCE_ROOT, on an SQLite file in a temporary
  # directory. The Gemfile line and the Ruflet app (which needs a client) are
  # left out.
  test "the RufletRecord examples run in page order" do
    lib = File.join(ENV["RUFLET_SOURCE_ROOT"].to_s, "packages/ruflet_record/lib")
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout with packages/ruflet_record" unless File.file?(File.join(lib, "ruflet_record.rb"))

    blocks = page.source.read.scan(/```ruby\n(.*?)```/m).flatten.reject do |code|
      code.start_with?("gem ") || code.include?("Ruflet.run")
    end
    assert_operator blocks.size, :>=, 10

    Dir.mktmpdir do |dir|
      program = +"start_time = Time.now.utc - 3600\nend_time = Time.now.utc + 3600\n"
      blocks.each { |code| program << code.gsub("__dir__", dir.inspect) << "\n" }
      program << "raise 'the queries found no rows' if User.count.zero?\nputs 'ok'\n"
      script = File.join(dir, "examples.rb")
      File.write(script, program)

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-rbundler/setup", "-I", lib, script, chdir: dir)
      assert status.success?, stderr
      assert_equal "ok", stdout.lines.last.to_s.strip
    end
  end
end
