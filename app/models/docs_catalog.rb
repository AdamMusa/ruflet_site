require "json"

class DocsCatalog
  Entry = Struct.new(:slug, :title, :summary, :source, :section, :content, keyword_init: true)
  Section = Struct.new(:id, :title, :entries, keyword_init: true)

  SOURCE_ROOT = Rails.root.join("app/content/docs")
  CONTROL_CATALOG_PATH = Rails.root.join("config/control_catalog.json")

  def self.sections
    @sections ||= [
      Section.new(
        id: "learn",
        title: "Learn",
        entries: [
          entry("introduction", "Introduction", "What Ruflet is, why it exists, and what the current platform and feature story looks like.", SOURCE_ROOT.join("introduction.md"), "Learn"),
          entry("installation", "Installation", "Install Ruflet, understand the package rename, and prepare your local Ruby workflow.", SOURCE_ROOT.join("installation.md"), "Learn"),
          entry("creating-a-new-app", "Creating a New Ruflet App", "Scaffold a new project, inspect the generated files, and understand `ruflet.yaml`.", SOURCE_ROOT.join("creating_a_new_app.md"), "Learn"),
          entry("app-structure", "App Structure", "Understand the generated files, the role of `main.rb`, `Gemfile`, and `ruflet.yaml`, and how Ruflet apps are organized.", SOURCE_ROOT.join("app_structure.md"), "Learn"),
          entry("running-a-ruflet-app", "Running a Ruflet App", "Run Ruflet for mobile, web, and desktop, and understand the core development loop.", SOURCE_ROOT.join("running_a_ruflet_app.md"), "Learn"),
          entry("cli-workflow", "CLI Workflow", "What `new`, `run`, `build`, `install`, `update`, and `doctor` do in a real Ruflet project.", SOURCE_ROOT.join("cli_workflow.md"), "Learn"),
          entry("testing-on-mobile", "Testing on Mobile", "Connect to the Ruflet mobile client and verify your app on real devices.", SOURCE_ROOT.join("testing_on_mobile.md"), "Learn"),
          entry("examples-overview", "Examples Overview", "See how the example apps build on the fundamentals and where to go next.", SOURCE_ROOT.join("examples_overview.md"), "Learn")
        ]
      ),
      Section.new(
        id: "tutorials",
        title: "Tutorials",
        entries: [
          entry("tutorial-calculator", "Calculator", "Build a small Ruflet calculator and learn buttons, layout, and state updates.", SOURCE_ROOT.join("tutorial_calculator.md"), "Tutorials"),
          entry("tutorial-todo", "ToDo", "Build a task list with filters, mutations, and realistic view composition.", SOURCE_ROOT.join("tutorial_todo.md"), "Tutorials"),
          entry("tutorial-solitaire", "Solitaire", "Study a larger interactive Ruflet app with richer state and custom presentation.", SOURCE_ROOT.join("tutorial_solitaire.md"), "Tutorials"),
          entry("examples", "Example Gallery", "A guided tour of the shipped demos and the fastest way to learn Ruflet by running code.", SOURCE_ROOT.join("examples.md"), "Tutorials")
        ]
      ),
      Section.new(
        id: "publishing",
        title: "Publishing",
        entries: [
          entry("build-and-release", "Build and Release", "Server-driven and self-contained builds, platform targets, assets, and release expectations.", SOURCE_ROOT.join("build_and_release.md"), "Publishing"),
          entry("publishing-android", "Android", "Package Android builds with Ruflet and decide between server-driven and self-contained delivery.", SOURCE_ROOT.join("publishing_android.md"), "Publishing"),
          entry("publishing-ios", "iOS", "Prepare iOS builds, client capabilities, and the right expectations for device testing.", SOURCE_ROOT.join("publishing_ios.md"), "Publishing"),
          entry("publishing-desktop", "Desktop", "Ship Ruflet apps for macOS, Windows, and Linux with one Ruby app layer.", SOURCE_ROOT.join("publishing_desktop.md"), "Publishing"),
          entry("publishing-web", "Web", "Run and ship Ruflet apps for the web with the same Ruby codebase.", SOURCE_ROOT.join("publishing_web.md"), "Publishing")
        ]
      ),
      Section.new(
        id: "integrations",
        title: "Integrations",
        entries: [
          entry("rails-integration", "Rails Integration", "Use Ruflet inside Rails with `ruflet_rails`, generated config, mounting, and app builds from Rails.", SOURCE_ROOT.join("rails_integration.md"), "Integrations"),
          entry("rails-scaffolding", "Scaffolding", "Generate a full CRUD resource as a single mountable Ruflet component.", SOURCE_ROOT.join("rails_scaffolding.md"), "Integrations"),
          entry("rails-navigation", "Navigation", "Flet-style routed view-stack navigation with `Ruflet::Rails.routed`.", SOURCE_ROOT.join("rails_navigation.md"), "Integrations"),
          entry("rails-assets", "Assets and URLs", "Display Rails assets as images with `asset_url`, the always-resolved `backend_url`, and the `ruflet_frame` ERB helper.", SOURCE_ROOT.join("rails_assets.md"), "Integrations"),
          entry("rails-webview-apps", "Webview Apps", "Wrap your website in a native shell with `webview_app` and the Hotwire Native-style `native_app`, plus the full WebView control.", SOURCE_ROOT.join("rails_webview_apps.md"), "Integrations"),
          entry("services-and-plugins", "Services and Plugins", "Built-in device APIs plus optional client extensions configured through `ruflet.yaml`.", SOURCE_ROOT.join("services_and_plugins.md"), "Integrations")
        ]
      ),
      Section.new(
        id: "reference",
        title: "Reference",
        entries: [
          entry("reference", "API Reference", "Overview of Ruflet controls, services, CLI workflow, and app structure.", SOURCE_ROOT.join("reference.md"), "Reference"),
          entry("component-reference", "Controls", "Browse Ruflet controls and open dedicated reference pages for each component.", SOURCE_ROOT.join("component_reference.md"), "Reference"),
          *control_entries
        ]
      )
    ]
  end

  def self.first
    sections.first.entries.first
  end

  def self.find(slug)
    sections.flat_map(&:entries).find { |entry| entry.slug == slug } || first
  end

  def self.all_entries
    sections.flat_map(&:entries)
  end

  def self.index_for(slug)
    all_entries.index { |entry| entry.slug == slug }
  end

  def self.previous_for(slug)
    index = index_for(slug)
    return nil unless index && index.positive?

    all_entries[index - 1]
  end

  def self.next_for(slug)
    index = index_for(slug)
    return nil unless index

    all_entries[index + 1]
  end

  def self.control_catalog
    @control_catalog ||= JSON.parse(CONTROL_CATALOG_PATH.read, symbolize_names: true).sort_by { |control| control[:title] }
  end

  def self.entry(slug, title, summary, source, section, content = nil)
    Entry.new(slug: slug, title: title, summary: summary, source: source, section: section, content: content)
  end

  def self.control_entries
    control_catalog.map do |control|
      source = source_for_slug(control[:slug])
      content = source ? nil : generated_control_markdown(control)
      summary = source ? nil : generated_control_summary(control)
      entry(control[:slug], control[:title], summary, source, "Reference", content)
    end
  end

  def self.source_for_slug(slug)
    path = SOURCE_ROOT.join("#{slug.tr('-', '_')}.md")
    path.exist? ? path : nil
  end

  def self.generated_control_summary(control)
    family = control[:family].to_s.sub(/s\z/, "").capitalize
    "#{family} control available in the current Ruflet packages."
  end

  def self.generated_control_markdown(control)
    helper = preferred_helper(control)
    lines = []
    lines << "# #{control[:title]}"
    lines << ""
    lines << "#{control[:title]} is available in the current Ruflet packages."
    lines << ""
    lines << "## Control Type"
    lines << ""
    lines << "- Family: `#{control[:family]}`"
    lines << "- Widget type: `#{control[:widget_type]}`"
    if helper
      lines << "- Preferred helper: `#{helper}`"
    else
      lines << "- Use through `control(:#{control[:widget_type]}, ...)`"
    end
    lines << ""
    lines << "## Common properties"
    lines << ""
    if control[:properties].any?
      control[:properties].each do |property|
        lines << "- `#{property}`"
      end
    else
      lines << "- Refer to the package control definition for the full property list."
    end
    lines << ""
    lines << "## Usage"
    lines << ""
    lines << "```ruby"
    lines.concat(generated_control_example(control, helper))
    lines << "```"
    lines << ""
    lines << "## Notes"
    lines << ""
    if helper
      lines << "- This control is supported through the `#{helper}` helper."
    else
      lines << "- This control is supported in Ruflet even though there is no dedicated helper in the current DSL."
    end
    lines << "- This page is generated from the current package snapshot used by the docs app."
    lines.join("\n")
  end

  def self.preferred_helper(control)
    helpers = Array(control[:helpers]).uniq
    return nil if helpers.empty?

    helpers.find { |name| name.include?("_") } || helpers.first
  end

  def self.generated_control_example(control, helper)
    method_call = helper || "control(:#{control[:widget_type]})"
    prop_lines = example_property_lines(control)

    if helper
      if prop_lines.empty?
        ["#{helper}"]
      else
        ["#{helper}(", *prop_lines.map { |line| "  #{line}" }, ")"]
      end
    else
      if prop_lines.empty?
        ["control(:#{control[:widget_type]})"]
      else
        ["control(:#{control[:widget_type]},", *prop_lines.map { |line| "  #{line}" }, ")"]
      end
    end
  end

  def self.example_property_lines(control)
    props = Array(control[:properties]).first(4)
    props.filter_map do |property|
      sample_value_for(property, control[:title])
    end
  end

  def self.sample_value_for(property, title)
    case property
    when "title"
      'title: text(value: "Title")'
    when "content"
      "content: text(value: \"#{title}\")"
    when "controls", "children", "actions", "tabs", "destinations"
      "#{property}: []"
    when "icon", "leading_icon", "trailing_icon", "selected_trailing_icon", "select_icon"
      "#{property}: \"add\""
    when "label", "hint_text", "helper_text", "cancel_text", "confirm_text"
      "#{property}: \"#{property.tr('_', ' ')}\""
    when "value"
      'value: "Sample"'
    when "text"
      'text: "Sample"'
    when "url"
      'url: "https://example.com"'
    when "open"
      "open: true"
    when "bgcolor"
      'bgcolor: "#111827"'
    when "width"
      "width: 240"
    when "height"
      "height: 120"
    when "expand"
      "expand: true"
    else
      nil
    end
  end

  private_class_method :entry, :control_entries, :source_for_slug, :generated_control_summary,
                       :generated_control_markdown, :preferred_helper, :generated_control_example,
                       :example_property_lines, :sample_value_for
end
