import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "tocLink"]

  connect() {
    this.headingElements = Array.from(this.element.querySelectorAll("[data-docs-heading]"))
    this.observeHeadings()
  }

  disconnect() {
    this.observer?.disconnect()
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
end
