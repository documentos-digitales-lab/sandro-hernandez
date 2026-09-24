import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    flash: { type: Array, default: [] },
    taxRate: { type: Number, default: 0.16 },
    highTaxThreshold: { type: Number, default: 2000 },
    requiredMessage: String,
    okMessage: String
  }

  static targets = ["quantity", "price", "amount", "description", "subtotal", "tax", "total", "banner", "submit"]

  connect() {
    this.showFlashErrors()
    this.update()
  }

  showFlashErrors() {
    this.flashValue.forEach((message) => {
      window.Toastify({
        text: message,
        duration: 4000,
        gravity: "top",
        position: "right",
        style: { background: "#dc3545" }
      }).showToast()
    })
  }

  update() {
    this.syncQuantityState()
    this.updateRows()
    this.updateTotals()
    this.updateTaxAssessment()
  }

  syncQuantityState() {
    this.quantityTargets.forEach((quantity, index) => {
      const disabled = parseInt(quantity.value, 10) === 0

      if (this.descriptionTargets[index]) {
        this.descriptionTargets[index].disabled = disabled
      }
      if (this.priceTargets[index]) {
        this.priceTargets[index].disabled = disabled
      }
    })
  }

  updateRows() {
    this.quantityTargets.forEach((_, index) => this.updateAmountRow(index))
  }

  updateAmountRow(index) {
    const amount = this.amountTargets[index]
    if (amount) {
      amount.textContent = this.formatMoney(this.quantity(index) * this.unitPrice(index))
    }
  }

  updateTotals() {
    const subtotal = this.rowAmounts().reduce((sum, value) => sum + value, 0)
    const tax = subtotal * this.taxRateValue

    this.subtotalTarget.textContent = this.formatMoney(subtotal)
    this.taxTarget.textContent = this.formatMoney(tax)
    this.totalTarget.textContent = this.formatMoney(subtotal + tax)
  }

  updateTaxAssessment() {
    const requiresAdditionalTaxes = this.perProductTaxes().some((tax) => tax > this.highTaxThresholdValue)
    const alertClass = requiresAdditionalTaxes ? "alert-warning" : "alert-success"
    const message = requiresAdditionalTaxes
      ? this.requiredMessageValue
      : this.okMessageValue

    this.bannerTarget.innerHTML =
      `<div class="alert ${alertClass} mb-0" role="alert">${message}</div>`

    this.submitTarget.disabled = requiresAdditionalTaxes
  }

  perProductTaxes() {
    return this.rowAmounts().map((amount) => amount * this.taxRateValue)
  }

  rowAmounts() {
    return this.quantityTargets.map((_, index) => this.quantity(index) * this.unitPrice(index))
  }

  quantity(index) {
    return parseFloat(this.quantityTargets[index]?.value) || 0
  }

  unitPrice(index) {
    return parseFloat(this.priceTargets[index]?.value) || 0
  }

  formatMoney(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}