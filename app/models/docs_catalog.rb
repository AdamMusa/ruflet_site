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
          entry("controls-and-layout", "Controls and Layout", "How controls, containers, and the layout model fit together.", SOURCE_ROOT.join("controls_and_layout.md"), "Reference"),
          entry("navigation-feedback", "Navigation and Feedback", "Views, dialogs, snackbars, bottom sheets, and other navigation and feedback patterns.", SOURCE_ROOT.join("navigation_feedback.md"), "Reference"),
          entry("charts-and-canvas", "Charts and Canvas", "Bar, line, pie, scatter, candlestick, and radar charts, plus canvas drawing primitives.", SOURCE_ROOT.join("charts_and_canvas.md"), "Reference"),
          entry("maps", "Maps", "Interactive maps with tile layers, markers, circles, and shapes.", SOURCE_ROOT.join("maps.md"), "Reference"),
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

  COMMON_PROPERTIES_PATH = Rails.root.join("config/control_common_properties.json")

  # Layout/animation properties shared by most controls — listed once as a note
  # rather than repeated on every page.
  def self.common_properties
    @common_properties ||=
      if COMMON_PROPERTIES_PATH.exist?
        JSON.parse(COMMON_PROPERTIES_PATH.read)
      else
        []
      end
  end

  # Ordered list of meaningful properties to reach for when building a sample.
  EXAMPLE_PROPERTY_PRIORITY = %w[
    value label text content title subtitle src url icon leading trailing
    options selected checked min max divisions password multiline color bgcolor
    open expand width height
  ].freeze

  def self.generated_control_markdown(control)
    helper = preferred_helper(control)
    props = Array(control[:properties]).map(&:to_s)
    events = Array(control[:events]).map(&:to_s)
    specific = props - common_properties

    lines = []
    lines << "# #{control[:title]}"
    lines << ""
    lines << "#{control[:title]} control. " +
             (helper ? "Build it with the `#{helper}` helper." : "Build it with `control(:#{control[:widget_type]}, ...)`.")
    lines << ""

    # --- Example ----------------------------------------------------------
    lines << "## Example"
    lines << ""
    lines << "```ruby"
    lines.concat(generated_control_example(control, helper))
    lines << "```"
    lines << ""

    # --- Properties -------------------------------------------------------
    lines << "## Properties"
    lines << ""
    if specific.any?
      specific.each { |property| lines << "- `#{property}`" }
      lines << ""
      lines << "Plus the common layout and animation properties shared by most " \
               "controls (`expand`, `visible`, `disabled`, `opacity`, `width`, " \
               "`height`, `align`, `tooltip`, `animate_*`, …)."
    elsif props.any?
      props.each { |property| lines << "- `#{property}`" }
    else
      lines << "- See the control definition for the full property list."
    end
    lines << ""

    # --- Events -----------------------------------------------------------
    if events.any?
      lines << "## Events"
      lines << ""
      events.each { |event| lines << "- `#{event}`" }
      lines << ""
    end

    # --- Reference --------------------------------------------------------
    lines << "## Reference"
    lines << ""
    lines << "- Family: `#{control[:family]}`"
    lines << "- Widget type: `#{control[:widget_type]}`"
    lines << "- Helper: #{helper ? "`#{helper}`" : "`control(:#{control[:widget_type]}, ...)`"}"
    lines.join("\n")
  end

  def self.preferred_helper(control)
    helpers = Array(control[:helpers]).uniq
    return nil if helpers.empty?

    helpers.find { |name| name.include?("_") } || helpers.first
  end

  def self.generated_control_example(control, helper)
    prop_lines = example_property_lines(control)

    return [helper || "control(:#{control[:widget_type]})"] if prop_lines.empty?

    open = helper ? "#{helper}(" : "control(:#{control[:widget_type]},"
    body = prop_lines.each_with_index.map do |line, index|
      "  #{line}#{index < prop_lines.length - 1 ? ',' : ''}"
    end
    [open, *body, ")"]
  end

  def self.example_property_lines(control)
    props = Array(control[:properties]).map(&:to_s)
    chosen = EXAMPLE_PROPERTY_PRIORITY.select { |p| props.include?(p) }.first(4)
    lines = chosen.filter_map { |property| sample_value_for(property, control[:title]) }

    # Add one representative event handler if the control has any.
    events = Array(control[:events]).map(&:to_s)
    event = %w[on_click on_change on_tap on_submit].find { |e| events.include?(e) } || events.first
    lines << "#{event}: ->(event) {}" if event

    lines
  end

  def self.sample_value_for(property, title)
    case property
    when "title"        then 'title: text("Title")'
    when "subtitle"     then 'subtitle: text("Subtitle")'
    when "content"      then "content: text(#{title.inspect})"
    when "controls", "children", "actions", "tabs", "destinations", "options"
      "#{property}: []"
    when "icon", "leading_icon", "trailing_icon", "selected_trailing_icon", "select_icon"
      "#{property}: \"add\""
    when "leading"      then 'leading: icon("menu")'
    when "trailing"     then 'trailing: icon("chevron_right")'
    when "label", "hint_text", "helper_text", "cancel_text", "confirm_text"
      "#{property}: #{property.tr('_', ' ').capitalize.inspect}"
    when "value"        then 'value: "Sample"'
    when "text"         then 'text: "Sample"'
    when "src"          then 'src: "https://example.com/image.png"'
    when "url"          then 'url: "https://example.com"'
    when "selected", "checked", "open" then "#{property}: true"
    when "password", "multiline"       then "#{property}: true"
    when "min"          then "min: 0"
    when "max"          then "max: 100"
    when "divisions"    then "divisions: 10"
    when "color"        then 'color: "#2563eb"'
    when "bgcolor"      then 'bgcolor: "#111827"'
    when "width"        then "width: 240"
    when "height"       then "height: 120"
    when "expand"       then "expand: true"
    end
  end

  private_class_method :entry, :control_entries, :source_for_slug, :generated_control_summary,
                       :generated_control_markdown, :preferred_helper, :generated_control_example,
                       :example_property_lines, :sample_value_for, :common_properties
end
