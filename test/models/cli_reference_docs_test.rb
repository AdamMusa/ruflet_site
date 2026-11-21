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
