require 'predictionio'
require 'figaro'
require 'ruby-progressbar'

namespace :predictionio do
  namespace :sync do
    task :users => :environment do
      users = Spree::User
      progressbar = ProgressBar.create(total: users.count)
      puts "Going to sync #{users.count} users"
      
      predictionio_client = PredictionIO::Client.new(ENV["PREDICTIONIO_API_KEY"])
      users.all.each do |user|
        predictionio_client.create_user(user.id)
        progressbar.increment
      end
    end

    task :products => :environment do
      products = Spree::Product
      progressbar = ProgressBar.create(total: products.count)
      puts "Going to sync #{products.count} products"
      
      predictionio_client = PredictionIO::Client.new(ENV["PREDICTIONIO_API_KEY"])
      products.all.each do |product|       
        product_property_data = Hash[(product.properties.map { |p| [p.name.to_sym, product.property(p.name)] })]
        # todo: Move this to some object so users can add their custom product attributes
        product_data = {pio_price: product.price,
                        name: product.name,
                        description: product.description,
                        permalink: product.permalink,
                        meta_description: product.meta_description,
                        meta_keywords: product.meta_keywords}
        product_data.merge! product_property_data
       
        magic_number_type_id = 1
        predictionio_client.create_item(product.id, 
                                        [magic_number_type_id,], 
                                        product_data)
        progressbar.increment
      end
    end


  end
end