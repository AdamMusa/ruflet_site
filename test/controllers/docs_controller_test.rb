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
end
