require "test_helper"
require "open3"
require "prism"

class RufletRecordDocsTest < ActiveSupport::TestCase
  MARKER = "**Requires the next Ruflet release** (on `main`, not in 0.0.23)".freeze

  def page = DocsCatalog.find("ruflet-record")

  test "the RufletRecord page is listed under Integrations" do
    assert_equal "ruflet-record", page.slug
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }
    assert_includes integrations.entries.map(&:slug), "ruflet-record"
  end

  # Everything else on the page is the published 0.0.23 gem.
  MAIN_ONLY_PARAGRAPHS = [
    "A subclass defined before its parent's `establish_connection` uses",
    "A `Time` is stored as its UTC time",
    "A `y` after a vowel stays in the plural",
    "`Post.new(user: user)`, `create` and `update` take a `belongs_to` name",
    "`has_many :addresses`, `:statuses`, `:buses` and `:aliases` find",
    "A range with an open end",
    "A `return`, `break` or `throw` out of the block commits",
    "A `Time` bind is converted to UTC",
    "> #{MARKER}"
  ].freeze

  test "only the main-only parts of the page carry the next-release marker" do
    prose = page.source.read.gsub(/```.*?```/m, "")
    marked = prose.split(/\n{2,}/).select { |paragraph| paragraph.include?(MARKER) }

    assert_equal MAIN_ONLY_PARAGRAPHS.size, marked.size, "Marked paragraphs:\n#{marked.join("\n\n")}"
    MAIN_ONLY_PARAGRAPHS.zip(marked).each do |opening, paragraph|
      assert paragraph.start_with?(opening), "Expected a marked paragraph starting #{opening.inspect}, got:\n#{paragraph}"
    end
    assert_includes prose[/^### Self-contained builds\n\n.*?\n/m].to_s, "> #{MARKER}"
    # The 0.0.23 behavior next to each change stays unmarked.
    assert_includes prose, "With 0.0.23, leave a transaction block"
    assert_includes prose, "With 0.0.23 such a range matches no rows"
  end

  # Runs the page's Ruby examples in order, as one program, against the
  # ruflet_record of Ruflet main (see main_record_lib), on an SQLite file in a
  # temporary directory. The Gemfile line and the Ruflet app (which needs a
  # client) are left out.
  test "the RufletRecord examples run in page order" do
    lib = main_record_lib
    skip "Set RUFLET_RECORD_MAIN_ROOT or RUFLET_SOURCE_ROOT to a Ruflet checkout with packages/ruflet_record" unless lib

    blocks = example_blocks.map(&:first)
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

  # The unmarked examples document the published 0.0.23 gem, so they must
  # also run on it and give what main gives. RUFLET_RECORD_RELEASE_ROOT is a
  # Ruflet checkout at b34072be, the commit that set ruflet_record's VERSION
  # to 0.0.23. Every statement's value is compared, and every relation is
  # loaded again once the examples have created rows (see the tracer), except
  # in a block whose introducing paragraph carries the next-release marker.
  test "the unmarked RufletRecord examples behave the same with 0.0.23" do
    main_lib = main_record_lib
    release_lib = record_lib("RUFLET_RECORD_RELEASE_ROOT")
    skip "Set RUFLET_RECORD_RELEASE_ROOT, and RUFLET_RECORD_MAIN_ROOT or RUFLET_SOURCE_ROOT, to Ruflet checkouts with packages/ruflet_record" unless main_lib && release_lib

    blocks = example_blocks
    main = trace_examples(main_lib, blocks.map(&:first))
    release = trace_examples(release_lib, blocks.map(&:first))

    compared = 0
    blocks.each_with_index do |(code, marked), index|
      next if marked

      compared += 1
      assert_equal main[index], release[index], "Example #{index + 1} gives a different result with 0.0.23; mark it or change it:\n#{code}"
    end
    assert_operator compared, :>=, 10
  end

  # Two changes after 0.0.23, the open-ended range fix (#107) and the
  # transaction-exit fix (#99), give 0.0.23's results unless a row tells them
  # apart (`age: 18..` finds nothing on either when every age is 0), so the
  # comparison above can miss them. The unmarked examples must not use them.
  test "the unmarked RufletRecord examples avoid what changed after 0.0.23" do
    example_blocks.each_with_index do |(code, marked), index|
      next if marked

      offenses = []
      each_node(Prism.parse(code).value) do |node|
        if node.is_a?(Prism::RangeNode) && [ node.left, node.right ].any? { |bound| bound.nil? || bound.is_a?(Prism::NilNode) }
          offenses << "an open-ended range (`#{node.slice}`)"
        elsif node.is_a?(Prism::CallNode) && node.name == :transaction && node.block.is_a?(Prism::BlockNode)
          each_node(node.block) do |inner|
            exit_call = inner.is_a?(Prism::CallNode) && inner.name == :throw
            offenses << "`#{inner.slice}` out of a transaction" if exit_call || inner.is_a?(Prism::ReturnNode) || inner.is_a?(Prism::BreakNode)
          end
        end
      end
      assert_empty offenses, "Example #{index + 1} uses what behaves differently on 0.0.23; mark it:\n#{code}"
    end
  end

  private
    def each_node(node, &block)
      yield node
      node.compact_child_nodes.each { |child| each_node(child, &block) }
    end

    def record_lib(variable)
      lib = File.join(ENV[variable].to_s, "packages/ruflet_record/lib")
      lib if ENV[variable].present? && File.file?(File.join(lib, "ruflet_record.rb"))
    end

    # The ruflet_record of Ruflet main. CI pins RUFLET_SOURCE_ROOT to the
    # commit the API catalogs come from, which can predate ruflet_record
    # changes, so RUFLET_RECORD_MAIN_ROOT, when set, takes precedence.
    def main_record_lib
      record_lib(ENV["RUFLET_RECORD_MAIN_ROOT"].present? ? "RUFLET_RECORD_MAIN_ROOT" : "RUFLET_SOURCE_ROOT")
    end

    # The page's Ruby blocks except the Gemfile line and the Ruflet app, each
    # with whether the paragraph directly before it carries the next-release
    # marker. Only such a block is main-only; a marker earlier in the section
    # does not make the blocks after it main-only.
    def example_blocks
      content = page.source.read
      content.to_enum(:scan, /```ruby\n(.*?)```/m).filter_map do
        match = Regexp.last_match
        code = match[1]
        next if code.start_with?("gem ") || code.include?("Ruflet.run")

        introduction = content[0...match.begin(0)].rstrip.split(/\n{2,}/).last.to_s
        [ code, introduction.include?(MARKER) ]
      end
    end

    def trace_examples(lib, blocks)
      Dir.mktmpdir do |dir|
        input = File.join(dir, "blocks.json")
        output = File.join(dir, "results.json")
        File.write(input, JSON.generate(blocks.map { |code| code.gsub("__dir__", dir.inspect) }))
        tracer = Rails.root.join("test/test_helpers/ruflet_record_example_trace.rb").to_s

        _stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-rbundler/setup", "-I", lib, tracer, input, output, chdir: dir)
        assert status.success?, "The RufletRecord examples fail with #{lib}:\n#{stderr}"
        JSON.parse(File.read(output))
      end
    end
end
