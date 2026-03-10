require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "gets docs index" do
    get docs_url

    assert_response :success
    assert_match "Creating a New Ruflet App", response.body
    assert_match "Rails integration", response.body
  end

  test "gets docs page" do
    get doc_url("widgets")

    assert_response :success
    assert_match "Widgets Guide", response.body
    assert_match "On this page", response.body
  end
end
