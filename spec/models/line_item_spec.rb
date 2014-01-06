require 'spec_helper'

describe Spree::LineItem do
  subject { FactoryGirl.create :line_item }

  describe ".sync_with_prediction_io" do
    it "should call prediction io with product's data" do
      prediction_io_client = double("prediction_io_client")
      prediction_io_client.should_receive(:identify).with(subject.order.user.id)
      prediction_io_client.should_receive(:record_action_on_item)
      subject.sync_with_prediction_io prediction_io_client
    end
  end
end