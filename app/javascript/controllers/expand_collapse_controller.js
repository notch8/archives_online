import { Controller } from "@hotwired/stimulus"

export default class ExpandCollapseController extends Controller {
  static targets = ["button"]
  static values = {
    expanded: { type: Boolean, default: false }
  }

  connect() {
    this.updateButtonText()
  }

  toggleAll(event) {
    event.preventDefault()
    
    const hierarchyContainer = this.getHierarchyContainer()
    if (!hierarchyContainer) return
    
    this.expandedValue ? this.collapseAll(hierarchyContainer) : this.expandAll(hierarchyContainer)
    
    this.expandedValue = !this.expandedValue
    this.updateButtonText()
  }

  getHierarchyContainer() {
    const container = this.element.querySelector('turbo-frame')
    if (!container) {
      console.error("Hierarchy container (turbo-frame) not found.")
    }
    return container
  }

  expandAll(container) {
    this.toggleElements(container, el => !el.classList.contains('show'))
    
    // Second pass: After a short delay, click any newly loaded collapsed items
    setTimeout(() => {
      this.toggleElements(container, el => !el.classList.contains('show'))
    }, 500)
  }

  collapseAll(container) {
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