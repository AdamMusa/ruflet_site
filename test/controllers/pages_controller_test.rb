require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "gets home" do
    get root_url

    assert_response :success
    assert_match "Build multi-platform apps in Ruby", response.body
    assert_match "Everything you need to build with Ruflet", response.body
    assert_match "Get Ruflet updates in your inbox", response.body
  end
end
