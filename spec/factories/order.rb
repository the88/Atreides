Factory.define :order, :class => Atreides::Order do |order|
  order.state               "pending"
  order.user_id             nil
  order.amount_cents        1000
  order.discount_cents      0
  order.final_amount_cents  1000
  order.currency            "EUR"
  order.ip_address          "::127"
  order.first_name          "John"
  order.last_name           "Doe"
  order.zip                 712
  order.country             "France"
  order.street              ""
  order.city                ""
  order.province            ""
  order.email               ""
  order.created_at          5.minutes.ago
  order.updated_at          5.minutes.ago
end

Factory.define :completed_order, :class => Atreides::Order, :parent => :order do |order|
  order.state               "completed"
  order.payment_gateway     ""
  order.gateway_data        ""
end

Factory.define :failed_order, :class => Atreides::Order, :parent => :order do |order|
  order.state               "failed"
  order.payment_gateway     ""
  order.gateway_data        ""
end