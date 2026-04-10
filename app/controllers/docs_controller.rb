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
      format.md { render markdown: File.read(@doc.source) }
    end
  end

  private

  def load_doc(slug)
    @sections = DocsCatalog.sections
    @doc = DocsCatalog.find(slug)
    markdown = File.read(@doc.source)
    @rendered_doc = MarkdownRenderer.render(markdown)
    @headings = @rendered_doc.headings.select { |heading| heading.level <= 3 }
    @previous_doc = DocsCatalog.previous_for(@doc.slug)
    @next_doc = DocsCatalog.next_for(@doc.slug)
  end
end
