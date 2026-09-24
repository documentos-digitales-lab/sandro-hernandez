class InvoicesController < ApplicationController
  include Pagy::Backend
  before_action :require_customer, only: [:new, :create, :index, :show]

  def index
    @pagy, @invoices = pagy(
      current_customer.invoices.order(created_at: :desc),
      items: 20)
    invoice_ids = @invoices.to_a.map(&:id)
    @products_count_by_invoice = Item.where(invoice_id: invoice_ids).group(:invoice_id).count
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
      render_new_with_items
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to invoice_path(current_customer.invoices.find_by!(uuid: @invoice.uuid))
  rescue ActionController::ParameterMissing
    @invoice = current_customer.invoices.new
    render_new_with_items
  end

  def show
    @invoice = current_customer.invoices.find_by!(uuid: params[:uuid])
    @additional_taxes = AdditionalTaxesChecker.call(@invoice)
  end

  private

  def render_new_with_items
    fill_missing_items
    render :new, status: :unprocessable_entity
  end

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