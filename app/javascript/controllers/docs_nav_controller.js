import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "tocLink", "searchDialog", "searchInput", "searchResults"]
  static values = { searchIndex: Array }

  connect() {
    this.headingElements = Array.from(this.element.querySelectorAll("[data-docs-heading]"))
    this.boundHandleDocumentKeydown = this.handleDocumentKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleDocumentKeydown)
    this.observeHeadings()
  }

  disconnect() {
    this.observer?.disconnect()
    document.removeEventListener("keydown", this.boundHandleDocumentKeydown)
  }

  toggleSidebar() {
    if (!this.hasSidebarTarget || !this.hasBackdropTarget) return

    this.sidebarTarget.classList.toggle("hidden")
    this.backdropTarget.classList.toggle("hidden")
  }

  closeSidebar() {
    if (this.hasSidebarTarget) this.sidebarTarget.classList.add("hidden")
    if (this.hasBackdropTarget) this.backdropTarget.classList.add("hidden")
  }

  openSearch() {
    if (!this.hasSearchDialogTarget) return

    this.searchDialogTarget.classList.remove("hidden")
    this.searchInputTarget.value = ""
    this.renderSearchResults("")
    window.requestAnimationFrame(() => this.searchInputTarget.focus())
  }

  closeSearch() {
    if (!this.hasSearchDialogTarget) return

    this.searchDialogTarget.classList.add("hidden")
    this.searchInputTarget.value = ""
    this.searchResultsTarget.innerHTML = ""
  }

  closeSearchFromBackdrop(event) {
    if (event.target !== this.searchDialogTarget) return

    this.closeSearch()
  }

  search() {
    const query = this.searchInputTarget.value.trim().toLowerCase()
    this.renderSearchResults(query)
  }

  handleSearchKeydown(event) {
    if (event.key !== "Escape") return

    this.closeSearch()
  }

  handleDocumentKeydown(event) {
    if (event.key === "Escape" && !this.searchDialogTarget.classList.contains("hidden")) {
      this.closeSearch()
      return
    }

    if (event.key.toLowerCase() !== "k" || (!event.metaKey && !event.ctrlKey)) return

    event.preventDefault()
    this.openSearch()
  }

  renderSearchResults(query) {
    if (!this.hasSearchResultsTarget) return

    if (query.length < 2) {
      this.searchResultsTarget.innerHTML = this.suggestionEntries().map((entry) => this.resultTemplate(entry, "Suggested")).join("")
      return
    }

    const terms = query.split(/\s+/).filter(Boolean)
    const matches = this.searchIndexValue
      .map((entry) => ({ entry, score: this.scoreEntry(entry, terms) }))
      .filter(({ score }) => score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 8)

    if (matches.length === 0) {
      this.searchResultsTarget.innerHTML = `<p class="docs-search-empty">No docs found for "${this.escapeHtml(query)}".</p>`
      return
    }

    this.searchResultsTarget.innerHTML = matches.map(({ entry }) => this.resultTemplate(entry)).join("")
  }

  suggestionEntries() {
    const preferredSlugs = ["component-reference", "controls-and-layout", "reference", "getting-started", "tutorial-calculator"]
    return preferredSlugs
      .map((slug) => this.searchIndexValue.find((entry) => entry.slug === slug))
      .filter(Boolean)
      .slice(0, 5)
  }

  resultTemplate(entry, label = entry.section) {
    return `
      <a class="docs-search-result" href="${entry.url}" data-action="click->docs-nav#closeSearch click->docs-nav#closeSidebar" role="option">
        <span class="docs-search-result-section">${this.escapeHtml(label)}</span>
        <span class="docs-search-result-title">${this.escapeHtml(entry.title)}</span>
        <span class="docs-search-result-summary">${this.escapeHtml(entry.summary || "")}</span>
      </a>
    `
  }

  scoreEntry(entry, terms) {
    const title = entry.title.toLowerCase()
    const section = entry.section.toLowerCase()
    const text = entry.text.toLowerCase()

    return terms.reduce((score, term) => {
      if (title.includes(term)) return score + 8
      if (section.includes(term)) return score + 4
      if (text.includes(term)) return score + 1
      return score
    }, 0)
  }

  escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (char) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      "\"": "&quot;",
      "'": "&#39;"
    }[char]))
  }

  observeHeadings() {
    if (this.headingElements.length === 0 || !this.hasTocLinkTarget) return

    this.observer = new IntersectionObserver(
      (entries) => {
        const activeEntry = entries
          .filter((entry) => entry.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)[0]

        if (!activeEntry) return

        const id = activeEntry.target.dataset.docsHeading
        this.tocLinkTargets.forEach((link) => {
          const active = link.dataset.headingId === id
          link.classList.toggle("docs-toc-link-active", active)
        })
      },
      { rootMargin: "-15% 0px -70% 0px", threshold: [0, 1] }
    )

    this.headingElements.forEach((heading) => this.observer.observe(heading))
  }

}
