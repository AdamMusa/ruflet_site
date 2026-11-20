require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "shows docs search with indexed controls" do
    get docs_url

    assert_response :success
    assert_select "button[aria-controls='docs-search-dialog']", text: /Search docs/
    assert_select "#docs-search-dialog[role='dialog']"
    assert_select "#docs-search-dialog input[type='search'][placeholder='Search widgets, guides...']"
    assert_match "data-docs-nav-search-index-value", response.body
    assert_match "TextField", response.body
    assert_match "control-text-field", response.body
  end

  test "redirects removed standalone API pages to the main reference" do
    %w[api-surface dsl-reference runtime-reference].each do |slug|
      get doc_url(slug)

      assert_response :moved_permanently
      assert_redirected_to doc_url("reference")
    end
  end

  test "redirects the old WebView Apps page to Native Shell" do
    get doc_url("rails-webview-apps")

    assert_response :moved_permanently
    assert_redirected_to doc_url("rails-native-shell")
  end

  test "names the managed WebView integration Native Shell" do
    entry = DocsCatalog.find("rails-native-shell")

    assert_equal "Native Shell", entry.title
    assert_includes entry.source.read, "# Native Shell"
  end

  test "groups the Rails API under integrations" do
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }
    reference = DocsCatalog.sections.find { |section| section.id == "reference" }

    assert_includes integrations.entries.map(&:slug), "rails-api-reference"
    refute_includes reference.entries.map(&:slug), "rails-api-reference"
  end

  test "catalog entries can belong to a parent documentation page" do
    entry = DocsCatalog.send(
      :entry,
      "child",
      "Child",
      "Nested documentation",
      Rails.root.join("README.md"),
      "Test",
      parent_slug: "parent"
    )

    assert_equal "parent", entry.parent_slug
  end

  test "shows ERB to Native widgets and services as nested navigation" do
    get doc_url("rails-erb-to-native")

    assert_response :success
    assert_select "ul[aria-label='ERB to Native']" do
      assert_select "a[href='#{doc_path("rails-native-components")}']", text: "Widgets"
      assert_select "a[href='#{doc_path("rails-native-services")}']", text: "Services"
    end
  end

  test "shows every Ruflet widget on the ERB to Native widgets page" do
    get doc_url("rails-native-components")

    assert_response :success
    assert_select "h1", text: "ERB to Native: Widgets"
    assert_select "[aria-label='Widgets catalog'] .docs-control-card", count: DocsCatalog.control_catalog.size
  end

  test "groups controls services and extensions separately" do
    controls = DocsCatalog.sections.find { |section| section.id == "controls" }
    services = DocsCatalog.sections.find { |section| section.id == "services" }
    extensions = DocsCatalog.sections.find { |section| section.id == "extensions" }
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }

    assert_includes controls.entries.map(&:slug), "component-reference"
    assert_equal "Widgets", controls.title
    assert_includes controls.entries.map(&:slug), "control-text"
    assert_includes services.entries.map(&:slug), "services-and-plugins"
    assert_includes extensions.entries.map(&:slug), "extensions"
    refute_includes extensions.entries.map(&:slug), "extension-secure-storage"
    assert_includes services.entries.map(&:slug), "service-secure-storage"
    assert_includes extensions.entries.map(&:slug), "extension-lottie"
    assert_includes extensions.entries.map(&:slug), "qrcode-scanner"
    assert_includes extensions.entries.map(&:slug), "extension-authoring"
    refute_includes integrations.entries.map(&:slug), "services-and-plugins"
    refute_includes integrations.entries.map(&:slug), "extension-authoring"
  end
end
