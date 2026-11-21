require "test_helper"
require "open3"

# Checks CLI reference claims against the ruflet gem this site bundles: the
# published release pinned in Gemfile.lock. The CLI runs in a separate process
# so the stubs below stay out of the other tests.
class CliReferenceDocsTest < ActiveSupport::TestCase
  MARKER = "**Requires the next Ruflet release**".freeze

  def source = DocsCatalog.find("cli-reference").source.read

  def run_released_cli(script, env = {})
    program = "require \"ruflet\"\nrequire \"ruflet/cli\"\n#{script}"
    stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, "-rbundler/setup", "-e", program, chdir: Rails.root.to_s)
    assert status.success?, stderr
    stdout
  end

  # The released CLI with a throwaway HOME, so nothing it caches or installs
  # touches the real ~/.ruflet.
  def run_released_cli_in_home(script)
    Dir.mktmpdir { |home| run_released_cli(script, "HOME" => home, "RUFLET_CLIENT_DIR" => "", "RUFLET_FLUTTER_VERSION" => "") }
  end

  # The paragraph or list item of `page` that contains `phrase`, on one line.
  def paragraph(page, phrase)
    text = DocsCatalog.find(page).source.read.split(/\n{2,}|\n(?=- )/).map(&:squish).find { |chunk| chunk.include?(phrase) }
    assert text, "#{page} no longer says #{phrase.inspect}"
    text
  end

  # A Flutter SDK installed the way `ruflet doctor --fix` installs one, in a
  # process where no flutter, fvm or dart is on PATH and Flutter's release
  # list cannot be fetched.
  MANAGED_FLUTTER_ONLY = <<~RUBY.freeze
    bin = File.join(Dir.home, ".ruflet", "flutter", "3.41.2", "macos_arm64", "flutter", "bin")
    FileUtils.mkdir_p(bin)
    File.write(File.join(bin, "flutter"), "#!/bin/sh\\necho '{\\"frameworkVersion\\":\\"3.41.2\\",\\"channel\\":\\"stable\\"}'\\n")
    File.chmod(0o755, File.join(bin, "flutter"))
    module Ruflet::CLI
      class << self
        def detect_client_dir = nil
        def resolve_ruflet_client_template_root = "/tmp/ruflet_flutter_template"
        def flutter_host = "macos_arm64"
        def which_command(*) = nil
        def desired_flutter_spec(**) = { channel: "stable", source: :metadata }
        def fetch_releases_manifest(*) = raise(SocketError, "getaddrinfo: nodename nor servname provided")
        def download_file(*) = raise("no download expected")
      end
    end
  RUBY

  # `ruflet run --web` finds its client through detect_web_client_dir. Here
  # the cache is complete, its update check is due, and GitHub answers 503.
  test "the cached-client fallback is marked exactly when the released CLI lacks it" do
    script = <<~RUBY
      module Ruflet::CLI
        class << self
          def prebuilt_assets_present?(*, **) = true
          def ensure_client_manifest(*, **) = nil
          def read_client_manifest(*) = {}
          def client_update_due?(*) = true
          def fetch_release_for_version(**) = raise("GitHub API failed (503)")
          def built_web_client_dir?(*) = true
        end
      end
      puts Ruflet::CLI.send(:detect_web_client_dir).inspect
    RUBY
    uses_cache = run_released_cli_in_home(script).strip != "nil"
    text = paragraph("configuration-reference", "using the cached one`, starts with the cached client")

    assert_equal !uses_cache, text.include?(MARKER), "ruflet #{Ruflet::VERSION} #{uses_cache ? 'uses' : 'does not use'} the cached client when the check fails"
  end

  test "plain doctor finding an installed managed Flutter SDK is marked exactly when the released CLI lacks it" do
    script = <<~RUBY
      require "fileutils"
      #{MANAGED_FLUTTER_ONLY}
      module Ruflet::CLI
        class << self
          def system(*, **) = true
        end
      end
      puts "code=\#{Ruflet::CLI.send(:command_doctor, [])}"
    RUBY
    finds_sdk = run_released_cli_in_home(script).lines.last.strip == "code=0"
    text = paragraph("cli-reference", "It still finds a Flutter SDK that `--fix` or a build installed earlier")

    assert_equal !finds_sdk, text.include?(MARKER), "plain `ruflet doctor` in ruflet #{Ruflet::VERSION} #{finds_sdk ? 'finds' : 'misses'} the installed SDK"
  end

  test "using an installed managed Flutter SDK offline is marked exactly when the released CLI lacks it" do
    script = <<~RUBY
      require "fileutils"
      #{MANAGED_FLUTTER_ONLY}
      begin
        puts Ruflet::CLI.send(:ensure_flutter!, "build").fetch(:flutter)
      rescue SystemExit
        puts "exit"
      end
    RUBY
    uses_sdk = run_released_cli_in_home(script).lines.last.strip != "exit"
    text = paragraph("cli-reference", "use an SDK already installed there instead of failing")

    assert_equal !uses_sdk, text.include?(MARKER), "`ruflet build` in ruflet #{Ruflet::VERSION} #{uses_sdk ? 'uses' : 'does not use'} the installed SDK offline"
  end

  # OptionParser accepts an unambiguous prefix of a long option, so the
  # released `ruflet debug` reads `--device` as `--device-id`.
  test "debug --device works in the released CLI and is not marked" do
    script = <<~RUBY
      module Ruflet::CLI
        class << self
          def detect_client_dir = Dir.pwd
          def ensure_flutter!(*) = { flutter: "flutter", env: {} }
          def system(_env, *command, **)
            puts command.join(" ")
            Kernel.system("true")
          end
        end
      end
      Ruflet::CLI.send(:command_debug, %w[android --device emulator-5554])
      Ruflet::CLI.send(:command_debug, %w[android --device=emulator-5556])
    RUBY

    assert_equal [ "flutter run -d emulator-5554", "flutter run -d emulator-5556" ], run_released_cli(script).lines.map(&:strip)
    line = source.lines.find { |candidate| candidate.start_with?("`--device ID` and `--device=ID` are other spellings of `--device-id ID`") }
    assert line, "Missing the --device spelling of ruflet debug"
    refute_includes line, MARKER, "`ruflet debug --device` works in ruflet #{Ruflet::VERSION} and must not be marked"
  end

  # The released `ruflet run` starts from --port (8550 by default) and passes
  # the port it picked to the app as RUFLET_PORT; it never reads RUFLET_PORT.
  test "the CLI reference does not say RUFLET_PORT sets the port of ruflet run" do
    script = <<~RUBY
      options = Ruflet::CLI.send(:parse_run_options, [])
      puts Ruflet::CLI.send(:resolve_backend_port, options[:target], requested_port: options[:requested_port])
    RUBY
    port = run_released_cli(script, "RUFLET_PORT" => "9123").to_i

    assert_operator port, :>=, 8550
    refute_equal 9123, port
    flat = source.squish
    assert_includes flat, "`ruflet run` passes the port it picked to the app as `RUFLET_PORT`"
    refute_match(/`RUFLET_PORT` (?:sets|provides|supplies) the (?:default|runtime default|server)/, flat)
    run_environment = source[/^- `run`: .*$/]
    assert run_environment, "Missing the run environment variables"
    refute_includes run_environment, "RUFLET_PORT"
  end
end
