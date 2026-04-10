class DocsCatalog
  Entry = Struct.new(:slug, :title, :summary, :source, :section, keyword_init: true)
  Section = Struct.new(:id, :title, :entries, keyword_init: true)

  SOURCE_ROOT = Rails.root.join("app/content/docs")

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
          entry("rails-integration", "Rails Integration", "Use Ruflet inside Rails with `ruflet_rails`, generated config, and app builds from Rails.", SOURCE_ROOT.join("rails_integration.md"), "Integrations"),
          entry("services-and-plugins", "Services and Plugins", "Built-in device APIs plus optional client extensions configured through `ruflet.yaml`.", SOURCE_ROOT.join("services_and_plugins.md"), "Integrations")
        ]
      ),
      Section.new(
        id: "reference",
        title: "Reference",
        entries: [
          entry("cli-workflow", "CLI Workflow", "What `new`, `run`, `build`, `install`, `update`, and `doctor` do in a real Ruflet project.", SOURCE_ROOT.join("cli_workflow.md"), "Reference"),
          entry("controls-and-layout", "Controls and Layout", "Core layout, text, buttons, lists, surfaces, forms, and adaptive UI building blocks.", SOURCE_ROOT.join("controls_and_layout.md"), "Reference"),
          entry("navigation-feedback", "Navigation and Feedback", "Views, navigation bars, tabs, sheets, banners, dialogs, snack bars, and event-driven updates.", SOURCE_ROOT.join("navigation_feedback.md"), "Reference"),
          entry("charts-and-canvas", "Charts and Canvas", "Charting, drawing primitives, and advanced visual controls used across Ruflet Studio.", SOURCE_ROOT.join("charts_and_canvas.md"), "Reference"),
          entry("component-reference", "Component Reference", "A high-level reference map of the control surface currently present in the Ruflet layer.", SOURCE_ROOT.join("component_reference.md"), "Reference")
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

  def self.entry(slug, title, summary, source, section)
    Entry.new(slug: slug, title: title, summary: summary, source: source, section: section)
  end

  private_class_method :entry
end
