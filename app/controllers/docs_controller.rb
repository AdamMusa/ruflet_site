class DocsController < ApplicationController
  allow_unauthenticated_access

  def index
    load_doc(DocsCatalog.first.slug)
    render :show
  end

  def show
    load_doc(params[:slug])

    respond_to do |format|
      format.html
      format.md { render markdown: doc_markdown }
    end
  end

  private

  def load_doc(slug)
    @sections = DocsCatalog.sections
    @doc = DocsCatalog.find(slug)
    markdown = doc_markdown
    @rendered_doc = MarkdownRenderer.render(markdown)
    @control_catalog = DocsCatalog.control_catalog
    @headings = @rendered_doc.headings.select { |heading| heading.level <= 3 }
    @previous_doc = DocsCatalog.previous_for(@doc.slug)
    @next_doc = DocsCatalog.next_for(@doc.slug)
  end

  def doc_markdown
    @doc.content || File.read(@doc.source)
  end
end
