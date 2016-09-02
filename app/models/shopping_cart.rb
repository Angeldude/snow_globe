class ShoppingCart

  # START: create_price_calculator
  attr_accessor :user, :discount_code_string

  def initialize(user, discount_code_string = nil)
    @user = user
    @discount_code_string = discount_code_string
  end

  def discount_code
    @discount_code ||= DiscountCode.find_by(code: discount_code_string)
  end

  def price_calculator
    @price_calculator ||= PriceCalculator.new(tickets, discount_code)
  end

  def total_cost
    price_calculator.total_price
  end

  delegate :processing_fee, to: :price_calculator

  def tickets
    @tickets ||= user.tickets_in_cart
  end
  # END: create_price_calculator

  def events
    tickets.map(&:event).uniq.sort_by(&:name)
  end

  def tickets_by_performance
    tickets.group_by { |t| t.performance.id }
  end

  def performance_count
    tickets_by_performance.each_pair.each_with_object({}) do |pair, result|
      result[pair.first] = pair.last.size
    end
  end

  def performances_for(event)
    tickets.map(&:performance)
        .select { |performance| performance.event == event }
        .uniq.sort_by(&:start_time)
  end

  def subtotal_for(performance)
    tickets_by_performance[performance.id].sum(&:price)
  end

  def item_attribute
    :ticket_ids
  end

  def item_ids
    tickets.map(&:id)
  end

end
