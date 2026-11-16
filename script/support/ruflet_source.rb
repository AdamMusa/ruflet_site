# frozen_string_literal: true

require "pathname"

# Finds the Ruflet Ruby sources the documentation scripts read. Shared by
# script/sync_ruflet_api and script/check_doc_examples.
module RufletSource
  DOCS_ROOT = Pathname.new(__dir__).join("../..").expand_path

  module_function

  def checkout_core_lib(root)
    root.join("packages/ruflet_core/lib").then { |path| path.directory? ? path : nil }
  end

  # packages/ruflet_core/lib from RUFLET_SOURCE_ROOT, a sibling checkout, or
  # the installed ruflet_core gem, in that order.
  def core_lib
    explicit = ENV["RUFLET_SOURCE_ROOT"].to_s.strip
    unless explicit.empty?
      root = Pathname.new(explicit).expand_path
      return checkout_core_lib(root) ||
        abort("Ruflet source not found at #{root} (expected packages/ruflet_core/lib).")
    end

    checkout_candidates = [
      # Izeesoft-style workspace: RailsApp/ruflet and FlutterApp/ruflet.
      DOCS_ROOT.join("../../FlutterApp/ruflet").expand_path,
      # Conventional sibling checkouts.
      DOCS_ROOT.join("../ruflet").expand_path,
      DOCS_ROOT.join("../Ruflet").expand_path
    ]
    checkout_candidates.each do |root|
      lib = checkout_core_lib(root)
      return lib if lib
    end

    require "rubygems"
    spec = Gem::Specification.find_by_name("ruflet_core")
    Pathname.new(spec.full_gem_path).join("lib")
  rescue Gem::MissingSpecError
    abort "Could not find a Ruflet source checkout or installed ruflet_core gem. Set RUFLET_SOURCE_ROOT."
  end

  # Puts ruflet_core (and ruflet_server beside it, when present) on the load
  # path and requires them.
  def load!(server: true)
    lib = core_lib
    $LOAD_PATH.unshift(lib.to_s)
    server_lib = lib.join("../../ruflet_server/lib").expand_path
    $LOAD_PATH.unshift(server_lib.to_s) if server_lib.directory?
    require "ruflet_core"
    require "ruflet_server" if server
    lib
  end
end
