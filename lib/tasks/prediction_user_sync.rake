require "predictionio"

predictionio_client = PredictionIO::Client.new(Figaro.env.prediction_io_api_key)

namespace :predictionio do
  namespace :sync do
    task :users => :environment
      Spree::Users.all.each do |user|
        p client.create_user(user.id)
      end
    end
  end
end