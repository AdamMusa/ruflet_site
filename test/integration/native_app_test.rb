require "test_helper"

class NativeAppTest < ActionDispatch::IntegrationTest
  test "starts with native feature controls" do
    page, = start_native_app
    values = native_texts(page.views.last)

    assert_equal 1, page.views.size
    assert_includes values, "Native UI, from Rails"
    assert_includes values, "Counter"
    assert_includes values, "Form"
    assert_includes values, "Device & media"
    assert_no_failed_controls(page)
  end

  test "counter actions rerender and keep connected sessions independent" do
    first_page, first_app = start_native_app("first")
    second_page, second_app = start_native_app("second")
    first_app.navigate("/native/counter", "push")
    second_app.navigate("/native/counter", "push")

    assert_includes native_texts(first_page.views.last), "0"
    2.times { first_app.action(url: "/native/counter_increment") }
    assert_includes native_texts(first_page.views.last), "2"
    assert_includes native_texts(second_page.views.last), "0"

    first_app.action(url: "/native/counter_decrement")
    second_app.action(url: "/native/counter_decrement")
    assert_includes native_texts(first_page.views.last), "1"
    assert_includes native_texts(second_page.views.last), "-1"
    assert_no_failed_controls(first_page)
    assert_no_failed_controls(second_page)
  end

  test "form submission displays submitted values as native controls" do
    page, app = start_native_app
    app.navigate("/native/form", "push")
    [
      [ "Name", "change", "Ada Lovelace" ],
      [ "Email", "change", "ada@example.com" ],
      [ "Language", "select", "fr" ]
    ].each do |label, event, value|
      field = native_controls(page.views.last).find { |control| control.props["label"] == label }
      assert field, "Missing native field: #{label}"
      page.dispatch_event(target: field.id, name: event, data: { "value" => value })
    end

    submit = native_controls(page.views.last).find do |control|
      control.has_handler?("click") && control.props["content"] == "Send"
    end
    assert submit, "Missing native submit button"
    page.dispatch_event(target: submit.id, name: "click", data: nil)

    values = native_texts(page.views.last)
    [ "Received!", "Ada Lovelace", "ada@example.com", "fr", "Yes" ].each do |value|
      assert_includes values, value
    end
    assert_no_failed_controls(page)
  end

  test "screen source rejects website actions and traversal before dispatch" do
    source = NativeScreenSource.new

    %w[
      /sessions/destroy /pages/home /native/send
      /native/../sessions/destroy /native/%2e%2e/sessions/destroy
    ].each do |path|
      assert_raises(ActionController::RoutingError, path) { source.fetch(path) }
    end
  end

  test "websocket endpoint is public and website remains available" do
    get "/ws"

    assert_response :bad_request
    assert_equal "Expected WebSocket upgrade", response.body

    get root_url

    assert_response :success
    assert_match "Build multi-platform apps in Ruby", response.body
  end

  test "storage demos only read and change their own demo key" do
    source = NativeScreenSource.new

    %w[preferences secure_storage].each do |feature|
      markup = source.fetch("/native/device_feature/#{feature}").body
      buttons = Nokogiri::HTML.fragment(markup).css("[service]")
      assert buttons.any?

      buttons.each do |button|
        next if button["service"] == "secure-availability"

        assert_includes %w[prefs-set prefs-get prefs-contains prefs-remove secure-set secure-get secure-contains secure-remove], button["service"]
        assert_equal "ruflet_demo", button["key"]
      end
    end
  end

  private

  def start_native_app(session_id = "native-test")
    page = Ruflet::Page.new(session_id: session_id, client_details: {}, sender: ->(*) { })
    app = Ruflet::Rails.erb_to_native(page, start_url: "/native", fetcher: NativeScreenSource.new)
    [ page, app ]
  end

  def native_controls(node)
    case node
    when Ruflet::Control
      [ node ] + native_controls(node.props) + native_controls(node.children)
    when Hash
      node.values.flat_map { |value| native_controls(value) }
    when Array
      node.flat_map { |value| native_controls(value) }
    else
      []
    end
  end

  def native_texts(node)
    native_controls(node).select { |control| control.type == "text" }
      .map { |control| control.props["value"].to_s }
  end

  def assert_no_failed_controls(page)
    failures = native_texts(page.views.last).select do |value|
      value.start_with?("⚠", "Screen failed", "No screen for", "Could not load screen")
    end
    assert_empty failures, failures.join("\n")
  end
end
