class DocsCatalog
  Entry = Struct.new(:slug, :title, :summary, :source, :section, keyword_init: true)
  Section = Struct.new(:id, :title, :entries, keyword_init: true)

  SOURCE_ROOT = Pathname.new("/Users/macbookpro/Documents/Izeesoft/FlutterApp/ruflet/docs")

  def self.sections
    @sections ||= [
      Section.new(
        id: "start",
        title: "Start here",
        entries: [
          entry("getting-started", "Creating a New Ruflet App", "CLI install, scaffold, run targets, and first app flow.", SOURCE_ROOT.join("creating_new_app.md"), "Start here"),
          entry("widgets", "Widgets Guide", "Class-based widget patterns, page basics, layout widgets, and events.", SOURCE_ROOT.join("widgets.md"), "Start here")
        ]
      ),
      Section.new(
        id: "shipping",
        title: "Shipping",
        entries: [
          entry("roadmap", "Ruflet Roadmap", "Current platform coverage, priorities, and the path toward broader Ruflet support.", SOURCE_ROOT.join("RUFLET_ROADMAP.md"), "Shipping")
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

  def self.entry(slug, title, summary, source, section)
    Entry.new(slug: slug, title: title, summary: summary, source: source, section: section)
  end

  private_class_method :entry
end
