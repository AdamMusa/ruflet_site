require "test_helper"
require "json"

class RufletServiceApiSyncTest < ActiveSupport::TestCase
  EXPECTED_HELPERS = %w[
    accelerometer audio_recorder barometer battery camera clipboard connectivity
    file_picker flashlight geolocator gyroscope haptic_feedback magnetometer
    permission_handler screen_brightness secure_storage semantics_service
    shake_detector share shared_preferences storage_paths url_launcher
    user_accelerometer wakelock
  ].freeze

  setup do
    @catalog = JSON.parse(Rails.root.join("config/service_catalog.json").read)
    @services = @catalog.fetch("services").index_by { |service| service.fetch("helper") }
  end

  test "all public service helpers have one source-generated entry" do
    assert_equal EXPECTED_HELPERS, @services.keys.sort
    assert_equal 24, @services.length

    @services.each do |helper, service|
      assert_equal helper, service.dig("page_accessor", "name")
      assert service.key?("properties")
      assert service.key?("events")
      assert service.key?("methods")
      assert service.key?("proxy_methods")
    end
  end

  test "service methods and proxy methods retain their callable signatures" do
    assert_equal %w[
      cancel_recording get_input_devices has_permission is_paused is_recording
      is_supported_encoder pause_recording resume_recording start_recording
      stop_recording
    ], method_names("audio_recorder")
    assert_equal %w[clear contains_key get get_all get_availability remove set], method_names("secure_storage")
    assert_equal %w[clear contains_key get get_keys remove set], proxy_method_names("shared_preferences")
    assert_equal %w[disable enable is_enabled], proxy_method_names("wakelock")

    start_recording = @services.fetch("audio_recorder").fetch("methods").find { |method| method.fetch("name") == "start_recording" }
    assert start_recording.fetch("parameters").any? { |kind, name| kind == "key" && name == "output_path" }
  end

  test "service properties and events follow the runtime schema classification" do
    accelerometer = @services.fetch("accelerometer")
    assert_equal %w[cancel_on_error data enabled interval key], accelerometer.fetch("properties")
    assert_equal %w[on_error on_reading], accelerometer.fetch("events")

    camera = @services.fetch("camera")
    assert_includes camera.fetch("properties"), "preview_enabled"
    assert_includes camera.fetch("events"), "on_stream_image"

    assert_includes @catalog.fetch("common_control_methods").map { |method| method.fetch("name") }, "on"
  end

  private

  def method_names(helper)
    @services.fetch(helper).fetch("methods").map { |method| method.fetch("name") }
  end

  def proxy_method_names(helper)
    @services.fetch(helper).fetch("proxy_methods").map { |method| method.fetch("name") }
  end
end
