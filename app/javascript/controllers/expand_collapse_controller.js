import { Controller } from "@hotwired/stimulus"

export default class ExpandCollapseController extends Controller {
  static targets = ["button"]
  static values = {
    expanded: { type: Boolean, default: false }
  }

  connect() {
    this.updateButtonText()
    this.isExpandingAll = false
    this.boundContinueExpanding = this.continueExpanding.bind(this)
    this.element.addEventListener("turbo:frame-load", this.boundContinueExpanding)
    console.log("ExpandCollapse controller connected")
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.boundContinueExpanding)
    console.log("ExpandCollapse controller disconnected")
  }

  toggleAll(event) {
    event.preventDefault()

    const hierarchyContainer = this.getHierarchyContainer()
    if (!hierarchyContainer) return

    this.expandedValue = !this.expandedValue
    this.updateButtonText()

    if (this.expandedValue) {
      this.isExpandingAll = true
      this.expandAll(hierarchyContainer)
    } else {
      this.isExpandingAll = false
      this.collapseAll(hierarchyContainer)
    }
  }

  getHierarchyContainer() {
    const container = this.element.querySelector('turbo-frame')
    if (!container) {
      console.error("Hierarchy container (turbo-frame) not found.")
    }
    return container
  }

  continueExpanding() {
    if (!this.isExpandingAll) return

    console.log("Frame loaded, checking for more items to expand...")
    const container = this.getHierarchyContainer()
    if (!container) return

    const clickedItemsCount = this.performExpansionPass(container)

    if (clickedItemsCount === 0) {
      console.log("Expansion complete.")
      this.isExpandingAll = false
      this.element.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }

  expandAll(container) {
    console.log("Initial expansion pass...")
    this.performExpansionPass(container)
  }

  performExpansionPass(container) {
    let clickCount = 0

    const toggles = container.querySelectorAll('a.al-toggle-view-children.collapsed')
    toggles.forEach(trigger => {
      const targetId = trigger.getAttribute('href')?.substring(1)
      const targetElement = targetId ? container.querySelector(`#${targetId}`) : null
      if (targetElement && !targetElement.classList.contains('show')) {
        trigger.click()
        clickCount++
      }
    })

    const paginators = container.querySelectorAll('a.btn[href*="/hierarchy?"]')
    paginators.forEach(paginator => {
      if (paginator.offsetParent !== null) {
        paginator.click()
        clickCount++
      }
    })
    console.log(`Performed ${clickCount} clicks in this pass.`)
    return clickCount
  }

  collapseAll(container) {
    this.isExpandingAll = false
    this.element.scrollIntoView({ behavior: "smooth", block: "start" });
    this.toggleElements(container, el => el.classList.contains('show'))
  }

  toggleElements(container, conditionCheck) {
    const triggers = container.querySelectorAll('a.al-toggle-view-children')
    triggers.forEach(trigger => {
      const targetId = trigger.getAttribute('href')?.substring(1)
      const targetElement = targetId ? container.querySelector(`#${targetId}`) : null
      if (targetElement && conditionCheck(targetElement)) {
        trigger.click()
      }
    })
  }

  updateButtonText() {
    this.buttonTarget.textContent = this.expandedValue ? "Collapse All" : "Expand All"
  }
}