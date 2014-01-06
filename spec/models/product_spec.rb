require 'spec_helper'

describe Spree::Product do
  subject { FactoryGirl.create :product }

  describe ".sync_with_prediction_io" do
    it "should call prediction io with product's data" do
      prediction_io_client = double("prediction_io_client")
      prediction_io_client.should_receive(:create_item)
      subject.sync_with_prediction_io prediction_io_client
    end
  end
end