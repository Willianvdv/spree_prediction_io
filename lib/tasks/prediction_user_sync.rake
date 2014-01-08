require 'predictionio'
require 'figaro'
require 'ruby-progressbar'

def check_for_engine engine_name
  raise "ERROR: No engine name is given. Usage is 'rake predictionio:pull:similar_products[<engine_name>]'" unless engine_name
end

namespace :predictionio do
  def predictionio_client
    @predictionio_client ||= PredictionIO::Client.new(ENV["PREDICTIONIO_API_KEY"])
  end

  namespace :pull do
    task :similar_products, [:engine_name] => :environment do |t, args|
      # Todo: This task is quite prototypish

      engine_name = args.engine_name
      check_for_engine engine_name

      relation_type = Spree::RelationType.where(:name => "similar", :applies_to => "Spree::Product").first_or_create
      
      products = Spree::Product
      progressbar = ProgressBar.create(total: products.count)

      products.all.each do |product|
        begin
          number_of_results = 10
          similar_product_ids = predictionio_client.get_itemsim_top_n(engine_name, product.id, number_of_results)
          similar_product_ids.each do |similar_product_id|
            similar_product = Spree::Product.find(similar_product_id)
            
            # Todo: Is this the nicest way?
            unless product.similars.include? similar_product
              relation = Spree::Relation.new(relation_type: relation_type)
              relation.relatable = product
              relation.related_to = similar_product
              relation.save
            end


            # Todo: Remove similars that not similar anymore!

          end
        rescue PredictionIO::Client::ItemSimNotFoundError => e; end
        progressbar.increment
      end
    end

    task :recommendations, [:engine_name] => :environment do |t, args|
      engine_name = args.engine_name
      check_for_engine engine_name

      users = Spree::User
      puts "Going to pull recommendations for #{users.count} users"

      users.all.each do |user|
        begin
          number_of_results = 10
          predictionio_client.identify(user.id)
          recommended_products = predictionio_client.get_itemrec_top_n(engine_name, number_of_results)
          
          # Todo: do something usefull with the results
          puts "Recommended products for #{user.id} (#{user.email}):"
          recommended_products.each do |recommended_product_id|
            recommended_product = Spree::Product.find(recommended_product_id)
            puts "\t- #{recommended_product.name}"
          end
        rescue PredictionIO::Client::ItemRecNotFoundError => e
          #puts "Recommendation not found"
        end
      end
    end
  end

  namespace :push do
    task :users => :environment do
      users = Spree::User
      progressbar = ProgressBar.create(total: users.count)
      puts "Going to push #{users.count} users"
      
      users.all.each do |user|
        user.sync_with_prediction_io predictionio_client
        progressbar.increment
      end
    end

    task :products => :environment do
      products = Spree::Product
      progressbar = ProgressBar.create(total: products.count)
      puts "Going to push #{products.count} products"
      
      products.all.each do |product|
        product.sync_with_prediction_io predictionio_client
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
        line_item.sync_with_prediction_io predictionio_client
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