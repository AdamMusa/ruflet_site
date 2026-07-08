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
end
