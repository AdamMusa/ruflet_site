require "test_helper"

class RufletExtensionDocsTest < ActiveSupport::TestCase
  EXPECTED_KEYS = %w[
    audio audio_recorder camera charts code_editor color_pickers datatable2
    flashlight geolocator lottie map permission_handler qrcode_scanner rive
    secure_storage video webview
  ].freeze

  test "every supported build extension has a dedicated documentation page" do
    assert_equal EXPECTED_KEYS, DocsCatalog.extension_catalog.map { |extension| extension.fetch(:key) }

    DocsCatalog.extension_catalog.each do |extension|
      slug = if Array(extension[:services]).any?
        "service-#{extension.fetch(:services).first.tr('_', '-')}"
      else
        extension[:guide] || "extension-#{extension.fetch(:key).tr('_', '-')}"
      end
      page = DocsCatalog.find(slug)

      assert_equal slug, page.slug
      assert_equal(Array(extension[:services]).any? ? "Services" : "Extensions", page.section)
      markdown = page.content || page.source.read
      assert_includes markdown, extension.fetch(:key)
      assert_includes markdown, extension.fetch(:package) if Array(extension[:services]).any?
    end
  end

  test "generated extension pages document package setup and their complete linked APIs" do
    DocsCatalog.extension_catalog.reject { |extension| extension[:guide] || Array(extension[:services]).any? }.each do |extension|
      page = DocsCatalog.find("extension-#{extension.fetch(:key).tr('_', '-')}")

      assert_includes page.content, extension.fetch(:package)
      assert_includes page.content, "ruflet.yaml"
      assert_includes page.content, "## API provided"
      assert_includes page.content, "## Permissions and platforms"
      assert_includes page.content, "## Build behavior"

      Array(extension[:properties]).each { |property| assert_includes page.content, "`#{property}`" }
      Array(extension[:events]).each { |event| assert_includes page.content, "`#{event}`" }
      Array(extension[:controls]).each { |slug| assert_includes page.content, "/docs/#{slug}" }
      Array(extension[:services]).each { |helper| assert_includes page.content, "/docs/service-#{helper.tr('_', '-')}" }
    end
  end

  test "every control extension has a usable highlighted Ruby example" do
    DocsCatalog.extension_catalog.reject { |extension| Array(extension[:services]).any? }.each do |extension|
      example = extension.fetch(:example)
      slug = extension[:guide] || "extension-#{extension.fetch(:key).tr('_', '-')}"
      page = DocsCatalog.find(slug)
      rendered = MarkdownRenderer.render(page.content || page.source.read).html

      RubyVM::InstructionSequence.compile(example)
      assert_operator example.lines.length, :>=, 3, extension.fetch(:key)
      assert_includes rendered, 'class="docs-code-block language-ruby"'
      assert_includes rendered, '<span class="tok-'
    end
  end

  test "extension catalog documents private packages Ruflet does not bundle" do
    content = DocsCatalog.find("extensions").source.read

    assert_includes content, "## Use an extension Ruflet does not bundle"
    assert_includes content, "git@github.com:acme/acme_widgets.git"
    assert_includes content, "config.extensions = ["
    assert_includes content, "path: packages/acme_widgets"
    assert_includes content, '<acme-rating value="4" maximum="5">'
    assert_includes content, "Ruflet does not copy or store repository credentials"
    assert_includes content, "Do not put a personal access token"
  end
end
