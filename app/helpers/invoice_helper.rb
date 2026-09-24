module InvoiceHelper
  def additional_taxes_message(required)
    if required
      "Additional taxes are needed for this invoice."
    else
      "No additional taxes are needed."
    end
  end

  def bootstrap_field_class(object, attribute)
    object.errors[attribute].any? ? "form-control is-invalid" : "form-control"
  end
end