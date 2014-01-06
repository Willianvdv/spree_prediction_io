Spree::LineItem.class_eval do
  def sync_with_prediction_io prediction_io_client
    prediction_io_client.identify order.user.id
    prediction_io_client.record_action_on_item("conversion", 
                                               product.id,
                                               prio_t: order.completed_at)

  end
end