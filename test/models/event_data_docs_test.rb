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
class EventDataDocsTest < ActiveSupport::TestCase
  test "a false event payload arrives in Ruby as nil" do
    root = ENV["RUFLET_SOURCE_ROOT"].presence
    skip "Set RUFLET_SOURCE_ROOT to a Ruflet checkout" unless root

    protocol = File.join(root, "packages/ruflet_core/lib/ruflet_protocol/ruflet/protocol.rb")
    script = <<~RUBY
      require #{protocol.dump}
      payload = { "target" => 1, "name" => "hover", "data" => false }
      p [Ruflet::Protocol.normalize_control_event_payload(payload)["data"],
         Ruflet::Protocol.normalize_control_event_payload(payload.merge("data" => true))["data"]]
    RUBY
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script)

    assert status.success?, stderr
    assert_equal "[nil, true]", stdout.strip,
      "Ruflet now passes a false event payload on: update the lines that say it arrives in Ruby as nil"
    %w[server.rb server/connection_protocol.rb].each do |file|
      source = File.read(File.join(root, "packages/ruflet_server/lib/ruflet", file))
      handler = source[/def on_control_event\(ws, payload\)\n(.*?)\n    end\n/m, 1]

      assert handler, "#{file} has no on_control_event"
      assert_includes handler, "Protocol.normalize_control_event_payload(payload)", file
    end
  end
end
