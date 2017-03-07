require 'spec_helper'

RSpec.describe ProjectProfile, type: :model do

  it "should respond to wizard_payload" do
    expect(ProjectProfile.new).to respond_to(:wizard_payload)
  end

  it "should respond to wizard_status" do
    expect(ProjectProfile.new).to respond_to(:wizard_status)
  end

  it "should respond to wizard_data" do
    expect(ProjectProfile.new).to respond_to(:wizard_data)
  end

  it "should respond to update_wizard_status" do
    expect(ProjectProfile.new).to respond_to(:update_wizard_status)
  end

  describe 'ProjectProfile#update_wizard_status' do

    it "should update wizard status" do
      profile = ProjectProfile.new
      profile.update_wizard_status('cost_control','done')
      profile.reload
      expect(profile.wizard_status('cost_control')).to eq('done')
    end

    it "should update wizard data" do
      profile = ProjectProfile.new
      profile.update_wizard_status('cost_control','done',{'test' => 'test'})
      profile.reload
      expect(profile.wizard_data('cost_control')).to eq({'test' => 'test'})
    end

    it "should reset wizard state to nil" do
      profile = ProjectProfile.new
      profile.update_wizard_status('cost_control',nil)
      profile.reload
      expect(profile.wizard_status('cost_control')).to be(nil)
    end

    it "should remove wizard data" do
      profile = ProjectProfile.new
      profile.update_wizard_status('cost_control',nil)
      profile.reload
      expect(profile.wizard_data('cost_control')).to be(nil)
    end
  end

  describe 'ProjectProfile#wizard_finished?' do
    context 'some services have not finished yet' do
      before :each do
        @profile = ProjectProfile.new
      end

      it "should return false" do
        expect(@profile.wizard_finished?('test1')).to eq(false)
      end

      it "should return false for multiple services" do
        expect(@profile.wizard_finished?('test1','test2')).to eq(false)
      end
    end

    context 'one service has finished' do
      before :each do
        @profile = ProjectProfile.new
        @profile.update_wizard_status('test1','done')
      end

      it "should return true" do
        expect(@profile.wizard_finished?('test1')).to eq(true)
      end

      it "should return false" do
        expect(@profile.wizard_finished?('test1','test2')).to eq(false)
      end
    end
  end

  describe 'ProjectProfile#wizard_status' do
    it "should return nil" do
      profile = ProjectProfile.new
      expect(profile.wizard_status('cost_control')).to be(nil)
    end
  end

  describe 'ProjectProfile#wizard_data' do
    it "should return nil" do
      profile = ProjectProfile.new
      expect(profile.wizard_data('cost_control')).to be(nil)
    end
  end
end
