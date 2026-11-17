require "test_helper"

class BuildConfigurationDocsTest < ActiveSupport::TestCase
  # Keys of Ruflet's CLIENT_EXTENSION_MAP (packages/ruflet/lib/ruflet/cli/build_command.rb) in 0.0.23.
  RELEASED_EXTENSION_KEYS = %w[
    ads audio audio_recorder camera charts code_editor color_pickers datatable2
    flashlight geolocator lottie map permission_handler qrcode_scanner rive
    secure_storage spinkit video webview
  ].freeze

  IOS_USAGE_KEYS = %w[
    NSCameraUsageDescription NSMicrophoneUsageDescription
    NSLocationWhenInUseUsageDescription NSLocationAlwaysAndWhenInUseUsageDescription
    NSMotionUsageDescription
  ].freeze

  ANDROID_PERMISSIONS = %w[
    android.permission.CAMERA android.permission.RECORD_AUDIO
    android.permission.ACCESS_COARSE_LOCATION android.permission.ACCESS_FINE_LOCATION
    android.permission.ACTIVITY_RECOGNITION android.permission.HIGH_SAMPLING_RATE_SENSORS
  ].freeze

  def source(slug) = DocsCatalog.find(slug).source.read

  test "configuration reference lists every released extension key" do
    listed = source("configuration-reference")[/^extensions:\n((?:  - \w+\n)+)/, 1].to_s.scan(/- (\w+)/).flatten

    assert_equal RELEASED_EXTENSION_KEYS, listed
  end

  test "extension catalog has a row for every released extension key" do
    content = source("extensions")

    RELEASED_EXTENSION_KEYS.each do |key|
      assert_match(/^\| \[`#{key}`\]\(/, content, "Missing extension row #{key}")
    end
  end

  test "publishing pages list the platform keys Ruflet writes for declarations" do
    ios = source("publishing-ios")
    android = source("publishing-android")

    IOS_USAGE_KEYS.each { |key| assert_includes ios, "`#{key}`" }
    ANDROID_PERMISSIONS.each { |permission| assert_includes android, "`#{permission}`" }
  end

  test "self-contained build docs cover runtime profiles and the web limit" do
    content = source("build-and-release")

    %w[--self --lite --full].each { |flag| assert_includes content, "`#{flag}`" }
    assert_includes content, "ruflet build ipa --self"
    assert_includes content, "--self is not supported for web"
    assert_includes content, "/docs/cli-reference"
  end

  test "ERB grid docs describe the responsive row mapping" do
    content = source("rails-native-components")

    assert_includes content, "`grid-cols-N`"
    assert_includes content, "`col-span-N`"
    assert_includes content, '<%= grid class: "grid-cols-3" do %>'
  end
end
