require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "gets home" do
    get root_url

    assert_response :success
    assert_match "Build multi-platform apps in Ruby", response.body
    assert_match "Everything you need to build with Ruflet", response.body
    assert_match "Get Ruflet updates in your inbox", response.body
    assert_match "Privacy Policy", response.body
  end

  test "gets privacy policy" do
    get privacy_url

    assert_response :success
    assert_match "Ruflet Explorer", response.body
    assert_match "Effective date: May 1, 2026", response.body
    assert_match "hello@ruflet.dev", response.body
  end
end
