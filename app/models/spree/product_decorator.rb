Spree::Product.class_eval do
  def sync_with_prediction_io prediction_io_client
    product_property_data = Hash[(properties.map { |p| [p.name.to_sym, property(p.name)] })]
    product_data = {pio_price: price,
                    name: name,
                    description: description,
                    permalink: permalink,
                    meta_description: meta_description,
                    meta_keywords: meta_keywords}
    product_data.merge! product_property_data   
    magic_number_type_id = 1
    prediction_io_client.create_item(id, [magic_number_type_id,], product_data)
  end
end