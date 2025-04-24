import { Controller } from "@hotwired/stimulus"

export default class ExpandCollapseController extends Controller {
  static targets = ["button", "hierarchy", "indicator"]
  static values = {
    expanded: { type: Boolean, default: false }
  }

  connect() {
    this.updateButtonText()
    this.isExpandingAll = false
    this.boundFrameLoadHandler = this.handleFrameLoad.bind(this);
    this.element.addEventListener("turbo:frame-load", this.boundFrameLoadHandler)
    this.safetyInterval = null;
    this.hideIndicator();
    this.consecutiveEmptyPasses = 0;
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.boundFrameLoadHandler)
    this.clearSafetyInterval();
    this.hideIndicator();
  }

  handleFrameLoad(event) {
    if (this.hasHierarchyTarget && this.hierarchyTarget.contains(event.target)) {
      this.continueExpanding();
    } else if (!this.hasHierarchyTarget) {
      this.continueExpanding();
    }
  }

  toggleAll(event) {
    event.preventDefault()
    this.clearSafetyInterval();

    const hierarchyContainer = this.getHierarchyContainer()
    if (!hierarchyContainer) return

    if (this.isExpandingAll && !this.expandedValue) { 
      this.isExpandingAll = false;
    }

    this.expandedValue = !this.expandedValue

    if (this.expandedValue) {
      this.isExpandingAll = true
      this.setBusyState(true)
      this.showIndicator();
      this.expandAll(hierarchyContainer)
      this.safetyInterval = setInterval(() => {
        this.continueExpanding();
      }, 750);
      setTimeout(() => {
        if (this.hasHierarchyTarget) {
          this.hierarchyTarget.classList.remove("is-expanding");
        }
      }, 750);

    } else {
      this.isExpandingAll = false 
      this.clearSafetyInterval();
      this.setBusyState(false)
      this.updateButtonText() 
      this.hideIndicator();
      this.collapseAll(hierarchyContainer)
    }
  }

  getHierarchyContainer() {
    if (!this.hasHierarchyTarget) {
      return this.element.querySelector('turbo-frame');
    }
    return this.hierarchyTarget
  }

  continueExpanding() {
    if (!this.isExpandingAll) {
      this.clearSafetyInterval();
      this.hideIndicator();
      return;
    }
    const container = this.getHierarchyContainer()
    if (!container) {
        return
    }

    const clickedItemsCount = this.performExpansionPass(container)

    if (clickedItemsCount > 0) {
      this.consecutiveEmptyPasses = 0;
    } else {
      this.consecutiveEmptyPasses++;
      const remainingToggles = container.querySelectorAll('a.al-toggle-view-children.collapsed').length;
      let remainingPaginators = 0;
      container.querySelectorAll('a.btn[href*="/hierarchy?"]').forEach(paginator => {
        if (paginator.offsetParent !== null) { remainingPaginators++; }
      });

      if (this.consecutiveEmptyPasses >= 2 && remainingToggles === 0 && remainingPaginators === 0) {
        this.isExpandingAll = false
        this.clearSafetyInterval();
        this.setBusyState(false);
        this.updateButtonText();
        this.hideIndicator();
        this.element.scrollIntoView({ behavior: "smooth", block: "start" })
      }
    }
  }

  expandAll(container) {
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
    const paginators = container.querySelectorAll('a.btn[href*="/hierarchy?"]:not(.is-loading)')
    paginators.forEach(paginator => {
      if (paginator.offsetParent !== null) {
        paginator.classList.add('is-loading');
        paginator.click()
        clickCount++
      }
    })
    return clickCount
  }

  collapseAll(container) {
    this.setBusyState(false)
    this.updateButtonText()
    this.hideIndicator();
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

  setBusyState(busy) {
    if (this.hasButtonTarget) {
        this.buttonTarget.disabled = busy;
        if (busy) {
            this.buttonTarget.textContent = "Expanding..."; 
        }
    }
    if (this.hasHierarchyTarget) {
        this.hierarchyTarget.classList.toggle("is-expanding", busy);
    }
  }

  updateButtonText() {
    if (this.hasButtonTarget && !this.buttonTarget.disabled) {
        this.buttonTarget.textContent = this.expandedValue ? "Collapse All" : "Expand All"
    }
  }

  clearSafetyInterval() {
    if (this.safetyInterval) {
      clearInterval(this.safetyInterval);
      this.safetyInterval = null;
    }
  }

  showIndicator() {
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.add("expansion-indicator--visible");
    }
  }

  hideIndicator() {
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.remove("expansion-indicator--visible");
    }
  }
}