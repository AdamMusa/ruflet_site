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

  test "only the main-only parts of the page carry the next-release marker" do
    content = page.source.read
    range = content[/^A range with an open end.*?(?=\n\n)/m]

    assert range, "Missing the open-ended range paragraph"
    assert_includes range, MARKER
    assert_includes content[/^### Self-contained builds\n\n.*?\n/m].to_s, "> #{MARKER}"
    # The rest of the page is the published 0.0.23 gem.
    transactions = content[/^## Transactions\n.*?(?=^## )/m].to_s
    assert_includes transactions[/^A `return`, `break` or `throw` out of the block commits.*?(?=\n\n|\z)/m].to_s, MARKER
    refute_includes transactions[/^With 0.0.23, leave a transaction block.*?(?=\n\n)/m].to_s, MARKER
    assert_equal 3, content.scan(MARKER).size
    refute_includes content[/\A.*?(?=^## Queries)/m], MARKER
  end

  # Runs the page's Ruby examples in order, as one program, against the
  # ruflet_record in RUFLET_SOURCE_ROOT, on an SQLite file in a temporary
  # directory. The Gemfile line and the Ruflet app (which needs a client) are
  # left out.
  test "the RufletRecord examples run in page order" do
    lib = record_lib("RUFLET_SOURCE_ROOT")
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout with packages/ruflet_record" unless lib

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
  # in the blocks that follow a next-release marker in their section.
  test "the unmarked RufletRecord examples behave the same with 0.0.23" do
    main_lib = record_lib("RUFLET_SOURCE_ROOT")
    release_lib = record_lib("RUFLET_RECORD_RELEASE_ROOT")
    skip "Set RUFLET_SOURCE_ROOT and RUFLET_RECORD_RELEASE_ROOT to Ruflet checkouts with packages/ruflet_record" unless main_lib && release_lib

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

  # ruflet_record changed after 0.0.23 only in the open-ended range fix (#107)
  # and the transaction-exit fix (#99). Comparing results misses them when no
  # row tells the two versions apart (`age: 18..` finds nothing on either when
  # every age is 0), so the unmarked examples must not use them at all.
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

    # The page's Ruby blocks except the Gemfile line and the Ruflet app, each
    # with whether a next-release marker comes before it in its section.
    def example_blocks
      content = page.source.read
      # The same text with the code blanked out, so a `#` comment in a block is
      # not taken for a heading.
      prose = content.gsub(/```.*?```/m) { |fence| fence.gsub(/[^\n]/, " ") }
      content.to_enum(:scan, /```ruby\n(.*?)```/m).filter_map do
        match = Regexp.last_match
        code = match[1]
        next if code.start_with?("gem ") || code.include?("Ruflet.run")

        section_start = prose[0...match.begin(0)].rindex(/^#+ /) || 0
        [ code, content[section_start...match.begin(0)].include?(MARKER) ]
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
