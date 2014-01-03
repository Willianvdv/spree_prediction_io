require 'predictionio'
require 'figaro'
require 'ruby-progressbar'

namespace :predictionio do
  def predictionio_client
    @predictionio_client ||= PredictionIO::Client.new(ENV["PREDICTIONIO_API_KEY"])
  end

  namespace :pull do
    task :similar_products, [:engine_name] => :environment do |t, args|
      engine_name = args.engine_name
      unless engine_name.nil?
        products = Spree::Product
        puts "Going to pull #{products.count} products"

        products.all.each do |product|
          begin
            number_of_results = 10
            similar_products = predictionio_client.get_itemsim_top_n(engine_name, product.id, number_of_results)
            
            # Todo: do something usefull with the results
            puts "#{product.name} relates to:"
            similar_products.each do |similar_product_id|
              similar_product = Spree::Product.find(similar_product_id)
              puts "\t- #{similar_product.name}"
            end
          rescue PredictionIO::Client::ItemSimNotFoundError => e
            #puts "Recommendation not found"
          end
        end
      else
        puts "ERROR: No engine name is given. Usage is 'rake predictionio:pull:similar_products[<engine_name>]'"
      end
    end
  end

  namespace :push do
    task :users => :environment do
      users = Spree::User
      progressbar = ProgressBar.create(total: users.count)
      puts "Going to push #{users.count} users"
      
      users.all.each do |user|
        predictionio_client.create_user(user.id)
        progressbar.increment
      end
    end

    task :products => :environment do
      products = Spree::Product
      progressbar = ProgressBar.create(total: products.count)
      puts "Going to push #{products.count} products"
      
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
      puts "Going to push #{line_items.count} line items"
      
      line_items.all.each do |line_item|
        order = line_item.order
        user = order.user
        product = line_item.product
        predictionio_client.identify user.id
        predictionio_client.record_action_on_item("conversion", 
                                                  product.id,
                                                  prio_t: order.completed_at)
        progressbar.increment
      end
    end

    task :all => :environment do
      Rake::Task["predictionio:push:users"].invoke
      Rake::Task["predictionio:push:products"].invoke
      Rake::Task["predictionio:push:line_items"].invoke
    end
  end
end