require "test_helper"

class RufletRuntimeApiSyncTest < ActiveSupport::TestCase
  RUNTIME_CATALOG_PATH = Rails.root.join("config/runtime_catalog.json")

  test "runtime catalog covers application namespaces and value types" do
    catalog = JSON.parse(RUNTIME_CATALOG_PATH.read)

    assert_equal Ruflet::VERSION, catalog.fetch("version")
    assert_equal(
      %w[Ruflet::Duration Ruflet::IconData Ruflet::Offset Ruflet::StrutStyle Ruflet::TextStyle Ruflet::WidgetBuilder],
      catalog.fetch("value_types").pluck("name")
    )
    assert_equal %w[colors icon_group icons ruflet_ui server], catalog.fetch("namespaces").keys.sort
    assert catalog.fetch("event_payloads").any? { |event| event.fetch("name") == "TapEvent" }
  end

  test "every documented control helper has a source-derived signature" do
    DocsCatalog.control_catalog.each do |control|
      helpers = control.fetch(:helpers)
      signatures = control.fetch(:helper_signatures).pluck(:name)

      assert_equal helpers.sort, signatures.sort, control.fetch(:title)
    end
  end

end
