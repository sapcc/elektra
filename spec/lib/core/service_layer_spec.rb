require 'spec_helper'

# describe Core::ServiceLayer::Services do
#
#   let(:dummy_class) { ActionController::Base.new { include Core::ServiceLayer::Services } }
#
#   describe 'current_region' do
#     it "dsdsd" do
#       dummy_class.new.current_region
#     end
#   end
# end

describe 'TestController', type: :controller do
  controller do
    include Core::ServiceLayer::Services
  end
  
  before :each do
    @current_user = double('current_user').as_null_object
    allow(controller).to receive(:current_user).and_return(@current_user)
  end
  
  describe 'current_region' do
    
    context 'default region is nil and default services region is nil' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return(nil)
        allow(@current_user).to receive(:default_services_region).and_return(nil)
      end
      
      it "should return nil" do
        expect(controller.current_region).to be(nil)
      end
    end
    
    context 'default region is nil and default services region exists' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return(nil)
        allow(@current_user).to receive(:default_services_region).and_return('europe')
      end
      
      it "should return default services region" do
        expect(controller.current_region).to eq('europe')
      end
    end
    
    context 'default region is a string and available regions contain default region' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return('europe')
        allow(@current_user).to receive(:available_services_regions).and_return(['de','us','europe'])
      end
      
      it "should return default region" do
        expect(controller.current_region).to eq('europe')
      end
    end
    
    context 'default region is a string and available regions does not contain default region' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return('europe')
        allow(@current_user).to receive(:available_services_regions).and_return(['de','us','es'])
        allow(@current_user).to receive(:default_services_region).and_return(@current_user.available_services_regions.first)
      end
      
      it "should return default_services_region" do
        expect(controller.current_region).to eq('de')
      end
    end
    
    context 'default region is a string and current_user is nil' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return('europe')
        allow(controller).to receive(:current_user).and_return(nil)
      end
      
      it "should return default region" do
        expect(controller.current_region).to eq('europe')
      end
    end
    
    context 'default region is an array and available regions contain default regions' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return(['europe','de'])
        allow(@current_user).to receive(:available_services_regions).and_return(['de','us','es','europe'])
      end
      
      it "should return first of default regions" do
        expect(controller.current_region).to eq('europe')
      end
    end
    
    context 'default region is an array and available regions contain default region' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return(['europe','de'])
        allow(@current_user).to receive(:available_services_regions).and_return(['de','us','es'])
      end
      
      it "should return last of default regions" do
        expect(controller.current_region).to eq('de')
      end
    end
    
    context 'default region is an array and available regions does not contain default regions' do
      before :each do
        allow(Rails.configuration).to receive(:default_region).and_return(['europe','ru'])
        allow(@current_user).to receive(:available_services_regions).and_return(['de','us','es'])
        allow(@current_user).to receive(:default_services_region).and_return(@current_user.available_services_regions.first)
      end
      
      it "should return last of available regions" do
        expect(controller.current_region).to eq('de')
      end
    end
  end
end