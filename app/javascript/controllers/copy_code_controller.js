import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "code"]

  async copy(event) {
    event.preventDefault()

    const code = this.codeTarget?.textContent || ""
    if (!code) {
      this.setState("Failed", {
        background: "#7f1d1d",
        borderColor: "rgba(248, 113, 113, 0.65)",
        color: "#fecaca"
      })
      return
    }

    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(code)
      } else {
        this.copyWithTextarea(code)
      }

      this.setState("Copied", {
        background: "#14532d",
        borderColor: "rgba(74, 222, 128, 0.75)",
        color: "#dcfce7"
      })
    } catch (_error) {
      this.setState("Failed", {
        background: "#7f1d1d",
        borderColor: "rgba(248, 113, 113, 0.65)",
        color: "#fecaca"
      })
    }
  }

  copyWithTextarea(code) {
    const textarea = document.createElement("textarea")
    textarea.value = code
    textarea.setAttribute("readonly", "")
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    textarea.style.pointerEvents = "none"
    document.body.appendChild(textarea)
    textarea.select()
    textarea.setSelectionRange(0, textarea.value.length)
    const success = document.execCommand("copy")
    document.body.removeChild(textarea)
    if (!success) throw new Error("copy failed")
  }

  setState(label, styles) {
    const button = this.buttonTarget
    const original = button.dataset.originalLabel || button.textContent || "Copy"
    button.dataset.originalLabel = original
    button.textContent = label
    Object.assign(button.style, styles)

    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      button.textContent = original
      button.style.background = "rgba(15, 23, 42, 0.96)"
      button.style.borderColor = "rgba(255, 255, 255, 0.12)"
      button.style.color = "#cbd5e1"
    }, 1600)
  }

  disconnect() {
    clearTimeout(this.resetTimer)
  }
}