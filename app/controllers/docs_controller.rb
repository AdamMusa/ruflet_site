class DocsController < ApplicationController
  def index
    load_doc(DocsCatalog.first.slug)
    render :show
  end

  def show
    load_doc(params[:slug])
  end

  private

  def load_doc(slug)
    @sections = DocsCatalog.sections
    @doc = DocsCatalog.find(slug)
    rendered = MarkdownRenderer.render(File.read(@doc.source))
    @content_html = rendered.html
    @toc = rendered.headings.select { |heading| heading.level <= 3 }
  end
end
