class DocsController < ApplicationController
  allow_unauthenticated_access

  def index
    load_doc(DocsCatalog.first.slug)
    render :show
  end

  def show
    if %w[api-surface dsl-reference runtime-reference].include?(params[:slug])
      redirect_to doc_path("reference"), status: :moved_permanently
      return
    end

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
    @search_index = DocsCatalog.search_index
    @headings = @rendered_doc.headings.select { |heading| heading.level <= 3 }
    @previous_doc = DocsCatalog.previous_for(@doc.slug)
    @next_doc = DocsCatalog.next_for(@doc.slug)
  end

  def doc_markdown
    @doc.content || File.read(@doc.source)
  end
end
