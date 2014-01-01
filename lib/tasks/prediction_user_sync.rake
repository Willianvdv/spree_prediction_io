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
  end
end