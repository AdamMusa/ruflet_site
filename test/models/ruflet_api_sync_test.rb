require "test_helper"
require "open3"

class RufletApiSyncTest < ActiveSupport::TestCase
  REQUIRED_PUBLIC_CONTROLS = %w[
    AnimatedSwitcher AutoCompleteSuggestion BarChart BarChartGroup BarChartRod
    BarChartRodStackItem CandlestickChart CandlestickChartSpot ChartAxis
    ChartAxisLabel CircleLayer CircleMarker LineChart LineChartData
    LineChartDataPoint Map Marker MarkerLayer PieChart PieChartSection
    PolygonLayer PolygonMarker PolylineLayer PolylineMarker RadarChart
    RadarChartTitle RadarDataSet RadarDataSetEntry RotatedBox ScatterChart
    ScatterChartSpot Screenshot Shadow SimpleAttribution SnackBarAction
    SubmenuButton TileLayer View
  ].freeze

  IMPLEMENTATION_ONLY_CONTROLS = %w[
    BasePage Dialogs FletApp Page Pagelet ServiceRegistry Window
  ].freeze

  test "checked-in control API matches the latest Ruflet source" do
    stdout, stderr, status = Open3.capture3(
      Rails.root.join("script/sync_ruflet_api").to_s,
      "--check",
      chdir: Rails.root.to_s
    )

    assert status.success?, [ stdout, stderr ].reject(&:empty?).join("\n")
  end

  test "catalog includes supported public builders and excludes internal or broken controls" do
    titles = DocsCatalog.control_catalog.map { |entry| entry.fetch(:title) }

    assert_empty REQUIRED_PUBLIC_CONTROLS - titles
    assert_empty IMPLEMENTATION_ONLY_CONTROLS & titles
    refute_includes titles, "Spinkit"
  end

  test "delegating builder aliases stay attached to their real control" do
    entries = DocsCatalog.control_catalog.index_by { |entry| entry.fetch(:title) }

    assert_includes entries.fetch("Button").fetch(:helpers), "elevated_button"
    assert_includes entries.fetch("FloatingActionButton").fetch(:helpers), "fab"
    refute entries.key?("ElevatedButton")
  end

  test "on-prefixed schema properties are not mislabeled as events" do
    entries = DocsCatalog.control_catalog.index_by { |entry| entry.fetch(:title) }

    assert_includes entries.fetch("CupertinoSwitch").fetch(:properties), "on_label_color"
    refute_includes entries.fetch("CupertinoSwitch").fetch(:events), "on_label_color"
    assert_includes entries.fetch("Semantics").fetch(:properties), "on_tap_hint_text"
    assert_includes entries.fetch("Semantics").fetch(:properties), "on_long_press_hint_text"
  end


  test "every control page renders every cataloged property and event" do
    DocsCatalog.control_catalog.each do |control|
      page = DocsCatalog.find(control.fetch(:slug))

      control.fetch(:properties).each do |property|
        assert_includes page.content, "`#{property}`", "#{control.fetch(:title)} property"
      end
      control.fetch(:events).each do |event|
        assert_includes page.content, "`#{event}`", "#{control.fetch(:title)} event"
      end
    end
  end

  test "open extension controls use client-derived contracts" do
    entries = DocsCatalog.control_catalog.index_by { |entry| entry.fetch(:title) }

    assert_includes entries.fetch("Map").fetch(:properties), "initial_center"
    assert_includes entries.fetch("Map").fetch(:events), "on_position_change"
    assert_includes entries.fetch("TileLayer").fetch(:properties), "enable_retina_mode"
    assert_includes entries.fetch("TileLayer").fetch(:events), "on_image_error"
    assert_includes entries.fetch("PolygonMarker").fetch(:properties), "label_text_style"
    assert_includes entries.fetch("SimpleAttribution").fetch(:events), "on_click"
  end

  test "Lottie is documented as a first-class DSL control" do
    lottie = DocsCatalog.control_catalog.find { |control| control.fetch(:title) == "Lottie" }

    assert_equal %w[lottie], lottie.fetch(:helpers)
    assert_includes lottie.fetch(:properties), "src"
    assert_includes lottie.fetch(:properties), "repeat"
    assert_includes lottie.fetch(:events), "on_load"
    assert_includes lottie.fetch(:events), "on_error"
    assert_includes DocsCatalog.find("extension-lottie").content, 'lottie(src: "assets/success.json", repeat: true)'
    refute_includes DocsCatalog.find("extension-lottie").content, 'control("Lottie"'
  end
end
