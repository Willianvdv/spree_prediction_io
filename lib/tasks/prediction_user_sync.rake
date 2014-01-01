require "predictionio"

namespace :predictionio do
  namespace :sync do
    task :users => :environment do
      predictionio_client = PredictionIO::Client.new(Figaro.env.PREDICTION_IO_API_KEY)
      Spree::Users.all.each do |user|
        p client.create_user(user.id)
      end
    end
  end
end