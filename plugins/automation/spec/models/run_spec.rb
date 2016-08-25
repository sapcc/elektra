require 'spec_helper'
require_relative '../factories/factories'

describe Automation::Run do

  describe 'snapshot' do

    it "should return an empty hash if no data available" do
      run = ::Automation::FakeFactory.new.run(automation_attributes: {})
      expect(run.snapshot).to eq({})

      run2 = ::Automation::FakeFactory.new.run(automation_attributes: nil)
      expect(run2.snapshot).to eq({})
    end

    it "should return a hash if data available" do
      run = ::Automation::FakeFactory.new.run
      expect(run.snapshot.to_json).to match(::Automation::FakeFactory.new.automation.to_json)
    end

  end

  describe 'revision_from_github?' do

    it "should return true if it is from localhost" do
      run = ::Automation::FakeFactory.new.run
      expect(run.revision_from_github?).to be_truthy
    end

    it "should return false for the other cases" do
      automation = ::Automation::FakeFactory.new.automation({repository: 'https://github.com/ids/chef-moo3.git'})
      run = ::Automation::FakeFactory.new.run({automation_attributes: automation})
      expect(run.revision_from_github?).to be_falsey
    end

  end

  describe 'revision_link' do

    it "should return a link" do
      run = ::Automation::FakeFactory.new.run
      expect(run.revision_link).to eq('https://localhost/ids/chef-moo3/commit/c7b3ee00635673294619070fafbccf27a23bcbd4')
    end

    it "should return just the revision sha if no github wdf repo" do
      automation = ::Automation::FakeFactory.new.automation({repository: 'https://github.com/ids/chef-moo3.git'})
      run = ::Automation::FakeFactory.new.run({automation_attributes: automation})
      expect(run.revision_link).to eq('c7b3ee00635673294619070fafbccf27a23bcbd4')
    end

  end

end