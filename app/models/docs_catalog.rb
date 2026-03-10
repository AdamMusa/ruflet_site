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
        id: "rails",
        title: "Rails integration",
        entries: [
          entry("rails-overview", "Ruflet Layer Overview", "How the Ruflet layer maps onto the protocol and serialization model.", SOURCE_ROOT.join("ruflet_layer/INDEX.md"), "Rails integration"),
          entry("rails-protocol", "Ruflet Layer Protocol", "Transport, frames, serialization, patch flow, and invoke-method handling.", SOURCE_ROOT.join("ruflet_layer/PROTOCOL.md"), "Rails integration")
        ]
      ),
      Section.new(
        id: "protocol",
        title: "Protocol reference",
        entries: [
          entry("python-index", "Python Layer Index", "Reference index for the extracted control surface and component model.", SOURCE_ROOT.join("flet_python_protocol/INDEX.md"), "Protocol reference"),
          entry("python-protocol", "Python Protocol Shape", "Envelope and extraction rules for the Python protocol shape.", SOURCE_ROOT.join("flet_python_protocol/PROTOCOL.md"), "Protocol reference")
        ]
      ),
      Section.new(
        id: "roadmap",
        title: "Roadmap",
        entries: [
          entry("roadmap", "Ruflet Roadmap", "Parity snapshot, gaps, and delivery phases for the runtime.", SOURCE_ROOT.join("RUFLET_ROADMAP.md"), "Roadmap")
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
