import { Controller } from "@hotwired/stimulus"

export default class ExpandCollapseController extends Controller {
  static targets = ["button", "hierarchy"]
  static values = {
    expanded: { type: Boolean, default: false }
  }

  connect() {
    this.updateButtonText()
    console.log("ExpandCollapse (Frame Reload Mode) controller connected")
  }

  toggleAll(event) {
    event.preventDefault()

    if (!this.hasHierarchyTarget) {
      console.error("Hierarchy turbo-frame target not found.")
      return
    }

    const frame = this.hierarchyTarget
    let currentSrc = frame.getAttribute("src")
    if (!currentSrc) {
      console.error("Hierarchy turbo-frame is missing src attribute.")
      return
    }

    const expand = !this.expandedValue
    let newSrc = currentSrc.replace(/[?&]expand_all=[^&]+/, "")

    const separator = newSrc.includes("?") ? "&" : "?"
    if (expand) {
      newSrc += `${separator}expand_all=true`
    }

    console.log(`Setting frame src to: ${newSrc}`)

    frame.src = newSrc

    this.expandedValue = expand
    this.updateButtonText()
  }

  updateButtonText() {
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = this.expandedValue ? "Collapse All" : "Expand All"
    }
  }
}