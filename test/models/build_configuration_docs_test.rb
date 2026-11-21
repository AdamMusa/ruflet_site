require "test_helper"
require "open3"
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

  # Environment variables one Ruflet process sets for another; not settings.
  INTERNAL_ENVIRONMENT = %w[
    RUFLET_APP_SCRIPT RUFLET_ASSETS_DIR RUFLET_BOOTSNAP_DIR RUFLET_RAILS_DESKTOP
    RUFLET_RAILS_DESKTOP_SERVER RUFLET_READY_FD RUFLET_RUNTIME_ERROR_FILE
    RUFLET_RUNTIME_PORT_FILE RUFLET_RUNTIME_TRANSPORT RUFLET_SUPPRESS_SERVER_BANNER
    RUFLET_TARGET RUFLET_URL RUFLET_WATCH_ROOT RUFLET_WEB_CLIENT_DIR
  ].freeze

  test "configuration reference names every environment variable the released gems read" do
    content = source("configuration-reference")
    read = %w[ruflet ruflet_core ruflet_server ruflet_rails].flat_map do |name|
      Dir[File.join(Gem.loaded_specs.fetch(name).full_gem_path, "lib", "**", "*.rb")].flat_map do |path|
        File.read(path).scan(/["'](RUFLET_[A-Z0-9_]+)["']/).flatten
      end
    end

    missing = read.uniq.sort - INTERNAL_ENVIRONMENT
    missing.reject! { |name| content.include?("`#{name}`") }
    assert_empty missing, "Undocumented environment variables (ruflet #{Ruflet::VERSION})"
  end

  PLATFORMS = %w[android ios web macos windows linux].freeze

  # Ruflet main declares every ruflet.yaml and services.yaml key in
  # cli/build/config_schema. The keys there are released too unless the page
  # marks them, so each must be named on the configuration reference: a key
  # only some platforms take under that platform's heading, the rest anywhere.
  # `splash_<platform>` on the page names the key for every platform.
  test "configuration reference names every key in Ruflet's config schema" do
    schema = config_schema_keys
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout with cli/build/config_schema" unless schema

    content = source("configuration-reference")
    named = ->(text) { text.scan(/`([a-z0-9_<>]+)`/).flatten.flat_map { |key| key.include?("<platform>") ? PLATFORMS.map { |platform| key.sub("<platform>", platform) } : key } }
    everywhere = named.call(content)
    sections = content[/^## Platform sections\n.*?(?=^## )/m].to_s.split(/^### `(\w+)`\n/).drop(1).each_slice(2).to_h { |name, text| [ name, named.call(text) ] }
    platform_key = /\A(?:(?:build|assets)\.)?(#{PLATFORMS.join('|')})\.([a-z0-9_]+)\z/
    by_platform = schema.filter_map { |path, _| path.match(platform_key)&.captures&.reverse }.group_by(&:first).transform_values { |pairs| pairs.map(&:last).uniq }

    missing = schema.filter_map do |path, type|
      next if type == "map"

      if (match = path.match(platform_key))
        leaf = match[2]
        platforms = by_platform.fetch(leaf)
        next if platforms.sort == PLATFORMS.sort ? everywhere.include?(leaf) : platforms.all? { |platform| Array(sections[platform]).include?(leaf) }
      else
        next if everywhere.include?(path.split(".").last)
      end
      path
    end

    assert_empty missing.uniq, "Config keys the configuration reference does not name"
  end

  def config_schema_keys
    root = ENV["RUFLET_SOURCE_ROOT"].to_s
    dir = File.join(root, "packages/ruflet/lib/ruflet/cli/build")
    return nil if root.empty? || !File.file?(File.join(dir, "config_schema.rb"))

    # A separate process: the schema lives in Ruflet::CLI, which the bundled
    # 0.0.23 gem defines too.
    script = <<~RUBY
      require "json"
      require #{File.join(dir, 'config_schema').inspect}
      Dir[#{File.join(dir, 'config_schema', '*.rb').inspect}].sort.each { |file| require file }
      schema = Ruflet::CLI::Build::ConfigSchema
      puts JSON.generate(%w[ruflet.yaml services.yaml].flat_map { |file| schema.keys(file: file).map { |key| [ key.path, key.type ] } })
    RUBY
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script)
    assert status.success?, stderr
    JSON.parse(stdout).uniq
  end

  test "ERB grid docs describe the responsive row mapping" do
    content = source("rails-native-components")

    assert_includes content, "`grid-cols-N`"
    assert_includes content, "`col-span-N`"
    assert_includes content, '<%= grid class: "grid-cols-3" do %>'
  end
end
