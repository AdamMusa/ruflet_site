import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.timeout = setTimeout(() => {
      this.messageTarget?.classList.add("opacity-0", "translate-y-[-8px]")
      setTimeout(() => this.element.remove(), 180)
    }, 3200)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
