import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }

  connect() {
    if (!this.messageValue) return

    window.Toastify({
      text: this.messageValue,
      duration: 5000,
      gravity: "top",
      position: "center",
      style: { background: "linear-gradient(to right, #00b09b, #96c93d)" }
    }).showToast()
  }
}