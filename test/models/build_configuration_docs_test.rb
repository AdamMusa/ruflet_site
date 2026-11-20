require "test_helper"
require "ruflet/cli"

# Checks the build-configuration pages against the mappings in Ruflet's build
# command, read from the ruflet gem this site bundles: the published release
# pinned in Gemfile.lock. Bumping that release fails these tests until the
# pages describe it.
class BuildConfigurationDocsTest < ActiveSupport::TestCase
  BUILD = Ruflet::CLI::BuildCommand
  MARKER = "**Requires the next Ruflet release**".freeze

  def source(slug) = DocsCatalog.find(slug).source.read

  # The first list item that starts with prefix. Released behavior is never marked.
  def released_item(content, prefix)
    line = content.lines.find { |candidate| candidate.start_with?(prefix) }

    assert line, "Missing list item starting with #{prefix.inspect} (ruflet #{Ruflet::VERSION})"
    refute_includes line, MARKER, "#{prefix.inspect} works in ruflet #{Ruflet::VERSION} and must not be marked"
    line
  end

  test "configuration reference lists every released extension key" do
    listed = source("configuration-reference")[/^extensions:\n((?:  - \w+\n)+)/, 1].to_s.scan(/- (\w+)/).flatten

    assert_equal BUILD::CLIENT_EXTENSION_MAP.keys.sort, listed, "ruflet #{Ruflet::VERSION}"
  end

  test "extension catalog has a row for every released extension key" do
    content = source("extensions")

    BUILD::CLIENT_EXTENSION_MAP.each_key do |key|
      assert_match(/^\| \[`#{key}`\]\(/, content, "Missing extension row #{key}")
    end
  end

  test "configuration reference states what extensions and declarations select" do
    content = source("configuration-reference")

    BUILD::EXTENSION_REQUIRED_SERVICES.each do |extension, services|
      services.each { |service| released_item(content, "- `#{extension}` writes the `#{service}` ") }
    end
    BUILD::PROTECTED_SERVICE_EXTENSIONS.each do |service, extensions|
      selected = extensions.map { |extension| "`#{extension}`" }.to_sentence

      assert_equal "- `#{service}` adds #{selected}.", released_item(content, "- `#{service}` adds ").strip
    end
  end

  test "configuration reference names every released services.yaml declaration" do
    paragraph = source("configuration-reference")[/^The supported declarations are .*?(?=\n\n)/m]

    assert paragraph, "Missing the supported-declarations paragraph"
    refute_includes paragraph[/\A[^.]*\./], MARKER, "The released declarations must not be marked"
    (BUILD::PROTECTED_SERVICE_EXTENSIONS.keys | BUILD::IOS_SERVICE_USAGE_KEYS.keys).each do |service|
      assert_includes paragraph, "`#{service}`", "Missing declaration #{service} (ruflet #{Ruflet::VERSION})"
    end
  end

  test "publishing pages list the platform keys Ruflet writes for declarations" do
    ios = source("publishing-ios")
    android = source("publishing-android")

    BUILD::IOS_SERVICE_USAGE_KEYS.each do |service, keys|
      line = released_item(ios, "- `#{service}` writes ")
      Array(keys).each { |key| assert_includes line, "`#{key}`" }
    end
    BUILD::ANDROID_SERVICE_PERMISSIONS.each do |service, permissions|
      line = released_item(android, "- `#{service}` adds ")
      permissions.each { |permission| assert_includes line, "`#{permission}`" }
    end
  end

  test "self-contained build docs cover runtime profiles and the web limit" do
    content = source("build-and-release")

    ([ "self" ] + BUILD::EMBEDDED_RUNTIME_PROFILES.map(&:to_s)).each { |flag| assert_includes content, "`--#{flag}`" }
    assert_includes content, BUILD::FULL_RUNTIME_MANIFEST
    assert_includes content, "ruflet build ipa --self"
    assert_includes content, "--self is not supported for web"
    assert_includes content, "/docs/cli-reference"
  end

  test "ERB grid docs describe the responsive row mapping" do
    content = source("rails-native-components")

    assert_includes content, "`grid-cols-N`"
    assert_includes content, "`col-span-N`"
    assert_includes content, '<%= grid class: "grid-cols-3" do %>'
  end
end
