require "test_helper"
require "open3"

# Event lines such as a button's on_hover say "the client sends `false`, which
# arrives in Ruby as `nil`". The Flutter client does send `false` (for example
# triggerEvent("hover", false)), but ruflet_server reads every control event
# through Protocol.normalize_control_event_payload, whose
# `payload["data"] || payload["eventData"]` turns `false` into `nil` before
# the handler runs. The Rails endpoint (ConnectionProtocol) and the embedded
# runtime use the same code. If Ruflet starts passing `false` through, these
# lines must change, and this test says so.
#
# A Hash payload, such as a tab bar's on_hover {"hovering" => false,
# "index" => 1}, is kept: normalize_event_data only turns its keys into
# symbols, so the tab bar line says `:hovering` is `true` or `false`.
class EventDataDocsTest < ActiveSupport::TestCase
  test "a false event payload arrives in Ruby as nil" do
    root = ENV["RUFLET_SOURCE_ROOT"].presence
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout" unless root

    protocol = File.join(root, "packages/ruflet_core/lib/ruflet_protocol/ruflet/protocol.rb")
    script = <<~RUBY
      require #{protocol.dump}
      payload = { "target" => 1, "name" => "hover", "data" => false }
      p [Ruflet::Protocol.normalize_control_event_payload(payload)["data"],
         Ruflet::Protocol.normalize_control_event_payload(payload.merge("data" => true))["data"],
         Ruflet::Protocol.normalize_control_event_payload(payload.merge("data" => { "hovering" => false, "index" => 1 }))["data"] == { "hovering" => false, "index" => 1 }]
    RUBY
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script)

    assert status.success?, stderr
    assert_equal "[nil, true, true]", stdout.strip,
      "Ruflet now changes how a false event payload arrives: update the lines that say it arrives in Ruby as nil, and the tab bar on_hover line"
    %w[server.rb server/connection_protocol.rb].each do |file|
      source = File.read(File.join(root, "packages/ruflet_server/lib/ruflet", file))
      handler = source[/def on_control_event\(ws, payload\)\n(.*?)\n    end\n/m, 1]

      assert handler, "#{file} has no on_control_event"
      assert_includes handler, "Protocol.normalize_control_event_payload(payload)", file
      assert_includes handler, "data: normalize_event_data(event[\"data\"])", file

      normalizer = source[/^    def normalize_event_data\(value\)\n.*?^    end\n/m]

      assert normalizer, "#{file} has no normalize_event_data"
      check = <<~RUBY
        helper = Object.new
        helper.instance_eval(#{normalizer.dump})
        p helper.normalize_event_data({ "hovering" => false, "index" => 1 }) == { hovering: false, index: 1 }
      RUBY
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", check)

      assert status.success?, "#{file}: #{stderr}"
      assert_equal "true", stdout.strip, "#{file}: a Hash payload no longer keeps its false values under symbol keys"
    end
  end
end
