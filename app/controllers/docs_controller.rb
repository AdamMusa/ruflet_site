class DocsController < ApplicationController
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
  end
end
