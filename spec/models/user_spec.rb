require 'spec_helper'

describe Spree.user_class do
  subject { FactoryGirl.create :user }

  describe ".sync_with_prediction_io" do
    it "should call prediction io" do
      prediction_io_client = double("prediction_io_client")
      prediction_io_client.should_receive(:create_user).with(subject.id)
      subject.sync_with_prediction_io prediction_io_client
    end
  end
end