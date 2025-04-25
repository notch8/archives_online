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

  disconnect() {
    // No listeners to remove
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

    // Determine the *new* desired state
    const expand = !this.expandedValue
    let newSrc = currentSrc.replace(/[?&]expand_all=[^&]+/, "") // Remove existing param

    // Construct new URL
    const separator = newSrc.includes("?") ? "&" : "?"
    if (expand) {
      newSrc += `${separator}expand_all=true`
    }

    console.log(`Setting frame src to: ${newSrc}`)

    // Set the new src to trigger Turbo Frame reload
    frame.src = newSrc

    // Update internal state and button text immediately
    this.expandedValue = expand
    this.updateButtonText() 
    // No need to disable button or wait for frame load for this simpler version
  }

  updateButtonText() {
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = this.expandedValue ? "Collapse All" : "Expand All"
    }
  }
}