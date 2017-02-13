require 'spec_helper'

RSpec.describe ProjectProfile, type: :model do

  it "should respond to wizard_payload" do
    expect(ProjectProfile.new).to respond_to(:wizard_payload)
  end

  it "should return default payload" do
    profile = ProjectProfile.new
    expect(profile.wizard_payload.keys.sort).to eq(ProjectProfile::INITIAL_WIZARD_PAYLOAD_SERVICES.sort)
  end

  it "should not overwrite registered services" do
    profile = ProjectProfile.new
    profile.wizard_payload = {'test' => 'test'}
    expect(profile.wizard_payload.keys.sort).to eq(ProjectProfile::INITIAL_WIZARD_PAYLOAD_SERVICES.sort)
  end

  it "should remove unregistered services from wizard payload" do
    profile = ProjectProfile.new
    profile.wizard_payload = {'cost_control' => 'skiped', 'test' => 'done'}
    profile.save
    profile.reload
    expect(profile.wizard_payload.keys.include?('test')).to be(false)
  end

  describe 'ProjectProfile#update_wizard_status' do
    it "should raise an error on unregistered service" do
      profile = ProjectProfile.new
      expect{
        profile.update_wizard_status('test','done')
      }.to raise_error(ProjectProfile::UnregisteredWizardService)
    end

    it "should not raise an error on registered service" do
      profile = ProjectProfile.new
      expect{
        profile.update_wizard_status('cost_control','done')
      }.not_to raise_error
    end

    it "should raise an error on bad status" do
      profile = ProjectProfile.new
      expect{
        profile.update_wizard_status('cost_control','pending')
      }.to raise_error(ProjectProfile::BadStatus)
    end

    it "should update wizard status" do
      profile = ProjectProfile.new
      profile.update_wizard_status('cost_control','done')
      profile.reload
      expect(profile.wizard_status('cost_control')).to eq('done')
    end
  end

  describe 'ProjectProfile#wizard_finished?' do
    it "should return true " do
      profile = ProjectProfile.new
      status = 'done'
      ProjectProfile::INITIAL_WIZARD_PAYLOAD_SERVICES.each do |key|
        profile.update_wizard_status(key,status)
        status = status=='done' ? 'skiped' : 'done'
      end
      expect(profile.wizard_finished?).to eq(true)
    end

    it "should return false" do
      profile = ProjectProfile.new
      expect(profile.wizard_finished?).to eq(false)
    end
  end

  describe 'ProjectProfile#wizard_status' do
    it "should return nil" do
      profile = ProjectProfile.new
      expect(profile.wizard_status('cost_control')).to be(nil)
    end
  end

  describe 'ProjectProfile#has_pending_wizard_services?' do
    it 'should return false' do
      profile = ProjectProfile.new
      expect(profile.has_pending_wizard_services?).to eq(false)
    end

    it 'should return true' do
      profile = ProjectProfile.new
      profile.update_wizard_status('networking',ProjectProfile::STATUS_SKIPED)
      expect(profile.has_pending_wizard_services?).to eq(true)
    end
  end
end
