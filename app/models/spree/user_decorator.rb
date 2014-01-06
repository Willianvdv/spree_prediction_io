Spree.user_class.class_eval do
  def sync_with_prediction_io prediction_io_client
    prediction_io_client.create_user(id)
  end
end