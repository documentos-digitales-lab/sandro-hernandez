import { Controller } from "@hotwired/stimulus"

// Mirrors of service constants: InvoiceTaxCalculator::TAX_RATE and
// AdditionalTaxesChecker::HIGH_TAX_THRESHOLD. The server is the authority
// at create/show — this only provides live preview feedback.
const TAX_RATE = 0.16
const HIGH_TAX_THRESHOLD = 2000

export default class extends Controller {
  static values = { flash: { type: Array, default: [] } }

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
    const tax = subtotal * TAX_RATE

    this.subtotalTarget.textContent = this.formatMoney(subtotal)
    this.taxTarget.textContent = this.formatMoney(tax)
    this.totalTarget.textContent = this.formatMoney(subtotal + tax)
  }

  updateTaxAssessment() {
    const requiresAdditionalTaxes = this.perProductTaxes().some((tax) => tax > HIGH_TAX_THRESHOLD)
    const alertClass = requiresAdditionalTaxes ? "alert-warning" : "alert-success"
    const message = requiresAdditionalTaxes
      ? "Additional taxes are needed for this invoice."
      : "No additional taxes are needed."

    this.bannerTarget.innerHTML =
      `<div class="alert ${alertClass} mb-0" role="alert">${message}</div>`

    this.submitTarget.disabled = requiresAdditionalTaxes
  }

  perProductTaxes() {
    return this.rowAmounts().map((amount) => amount * TAX_RATE)
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