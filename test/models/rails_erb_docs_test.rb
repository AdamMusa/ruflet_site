require "test_helper"

class RailsErbDocsTest < ActiveSupport::TestCase
  WIDGET_HELPERS = %w[
    column row stack container section card center list grid spacer divider
    text markdown icon image heading h1 h2 h3 h4 h5 h6 button link appbar
    appbar_action fab bottom_nav nav_item badge tooltip avatar chip progress
    switch checkbox slider radio list_tile expansion_tile radio_group
    segmented_button tabs tab form input textarea submit dropdown video lottie
    code_editor map web_view color_picker camera bar_chart line_chart pie_chart
    scatter_chart candlestick_chart radar_chart tile_layer marker_layer marker
    circle_layer circle_marker polyline_layer polyline_marker polygon_layer
    polygon_marker simple_attribution bar_chart_group bar_chart_rod
    bar_chart_rod_stack_item line_chart_data line_chart_data_point
    pie_chart_section candlestick_chart_spot scatter_chart_spot radar_dataset
    radar_dataset_entry radar_chart_title chart_axis chart_axis_label rive
    spinkit widget
  ].freeze

  DECLARATIVE_SERVICE_HELPERS = %w[
    accelerometer audio audio_recorder barometer battery clipboard connectivity
    file_picker flashlight geolocator gyroscope haptic_feedback magnetometer
    permission_handler screen_brightness secure_storage semantics_service
    shake_detector share shared_preferences storage_paths url_launcher
    user_accelerometer wakelock
  ].freeze

  test "widget reference covers every named ERB helper" do
    content = DocsCatalog.find("rails-native-components").source.read

    WIDGET_HELPERS.each do |helper|
      assert_includes content, "`#{helper}`", "Missing ERB widget helper #{helper}"
    end

    assert_includes content, '<progress-ring value="0.65"'
    assert_includes content, '<%= lottie src:'
    assert_includes content, '<%= camera id:'
  end

  test "service reference covers every declarative ERB service" do
    content = DocsCatalog.find("rails-native-services").source.read

    DECLARATIVE_SERVICE_HELPERS.each do |helper|
      assert_includes content, "`#{helper}`", "Missing ERB service helper #{helper}"
    end

    assert_includes content, "Services use normal ERB helpers too."
  end

  test "service reference links every core Ruflet service" do
    content = DocsCatalog.find("rails-native-services").source.read

    DocsCatalog.service_catalog.fetch(:services).each do |service|
      helper = service.fetch(:helper)
      slug = "service-#{helper.tr("_", "-")}"

      assert_includes content, "/docs/#{slug}", "Missing service reference #{slug}"
    end
  end

  test "Rails integration presents native ERB and WebView as separate modes" do
    integration = DocsCatalog.find("rails-integration").source.read
    api = DocsCatalog.find("rails-api-reference").source.read

    assert_includes integration, "Ruflet::Rails.erb_to_native"
    assert_includes integration, "Ruflet::Rails.native_app"
    assert_includes api, "Ruflet::Rails.erb_to_native"
    assert_includes api, "Ruflet::Rails.native_app"
  end
end
