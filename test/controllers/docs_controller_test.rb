require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "shows docs search with indexed controls" do
    get docs_url

    assert_response :success
    assert_select "button[aria-controls='docs-search-dialog']", text: /Search docs/
    assert_select "#docs-search-dialog[role='dialog']"
    assert_select "#docs-search-dialog input[type='search'][placeholder='Search components, guides...']"
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

  test "groups the Rails API under integrations" do
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }
    reference = DocsCatalog.sections.find { |section| section.id == "reference" }

    assert_includes integrations.entries.map(&:slug), "rails-api-reference"
    refute_includes reference.entries.map(&:slug), "rails-api-reference"
  end

  test "groups controls services and extensions separately" do
    controls = DocsCatalog.sections.find { |section| section.id == "controls" }
    services = DocsCatalog.sections.find { |section| section.id == "services" }
    extensions = DocsCatalog.sections.find { |section| section.id == "extensions" }
    integrations = DocsCatalog.sections.find { |section| section.id == "integrations" }

    assert_includes controls.entries.map(&:slug), "component-reference"
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
