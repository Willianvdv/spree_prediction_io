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

   task :line_items => :environment do
      line_items = Spree::LineItem.joins(:order)
                                  .where('spree_orders.user_id is not null')
                                  .where('spree_orders.completed_at IS NOT NULL')
      progressbar = ProgressBar.create(total: line_items.count)
      puts "Going to sync #{line_items.count} line items"
      
      predictionio_client = PredictionIO::Client.new(ENV["PREDICTIONIO_API_KEY"])
      line_items.all.each do |line_item|
        order = line_item.order
        user = order.user
        product = line_item.product
        predictionio_client.identify user.id
        predictionio_client.record_action_on_item("conversion", 
                                                  pio_iid: product.id,
                                                  prio_t: order.completed_at)
        progressbar.increment
      end
    end

    task :all => :environment do
      Rake::Task["predictionio:sync:users"].invoke
      Rake::Task["predictionio:sync:products"].invoke
      Rake::Task["predictionio:sync:line_items"].invoke
    end
  end
end