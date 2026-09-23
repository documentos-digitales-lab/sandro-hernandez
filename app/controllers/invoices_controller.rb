class InvoicesController < ApplicationController
  before_action :require_customer, only: [:new, :create, :index, :show]

  def index
    @invoices = current_customer.invoices.order(created_at: :desc)
  end

  def new
    @invoice = Invoice.new(customer_id: current_customer.id)
    fill_missing_items
  end

  def create
    @invoice = current_customer.invoices.new(invoice_params)
    if @invoice.save
      redirect_to invoice_path(@invoice)
    else
      fill_missing_items
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to invoice_path(current_customer.invoices.find_by!(uuid: @invoice.uuid))
  end

  def show
    @invoice = current_customer.invoices.find_by!(uuid: params[:uuid])
    @taxes = InvoiceTaxCalculator.call(@invoice)
    @additional_taxes = AdditionalTaxesChecker.call(@invoice)
  end

  private

  def fill_missing_items
    return if @invoice.items.size >= 2

    @invoice.items.build(quantity: 1) if @invoice.items.empty?
    @invoice.items.build(quantity: 0)
  end

  def invoice_params
    params.require(:invoice).permit(
      items_attributes: [:description, :quantity, :unit_price])
  end
end