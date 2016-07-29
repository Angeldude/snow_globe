## START: purchases_cart_init
class PurchasesCart

  attr_accessor :user, :purchase_amount_cents,
      :purchase_amount, :success,
      :payment, :expected_ticket_ids

  def initialize(user: nil, purchase_amount_cents: nil, expected_ticket_ids: "")
    @user = user
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
    @continue = true
    @expected_ticket_ids = expected_ticket_ids.split(" ").map(&:to_i).sort
  end

  def run
    Payment.transaction do
      pre_purchase
      purchase
      post_purchase
      @success = @continue
    end
  end
  ## END: purchases_cart_init

  ## START: purchases_pre_purchase
  def pre_purchase_valid?
    purchase_amount == tickets.map(&:price).sum &&
        expected_ticket_ids == tickets.map(&:id).sort
  end

  def tickets
    @tickets ||= @user.tickets_in_cart
  end

  def pre_purchase
    unless pre_purchase_valid?
      @continue = false
      return
    end
    update_tickets
    create_payment
    @continue = true
  end

  def redirect_on_success_url
    nil
  end

  def create_payment
    self.payment = Payment.create!(payment_attributes)
    payment.create_line_items(tickets)
  end
  ## END: purchases_pre_purchase

  def payment_attributes
    {user_id: user.id, price_cents: purchase_amount.cents,
     status: "created", reference: Payment.generate_reference}
  end

  def success?
    success
  end

  ## START: reverse_purchase
  def unpurchase_tickets
    tickets.each(&:waiting!)
  end

  def reverse_purchase
    unpurchase_tickets
    @continue = false
  end
  ## END: reverse_purchase

  ## START: purchases_post_charge

  def calculate_success
    payment.succeeded?
  end

  def post_purchase
    return unless @continue
    @continue = calculate_success
  end
  ## END: purchases_post_charge

end
