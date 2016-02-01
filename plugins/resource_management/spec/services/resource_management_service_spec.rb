require 'spec_helper'

RSpec.describe ServiceLayer::ResourceManagementService do

  before(:all) { ResourceManagement::Resource.mock!   }
  after (:all) { ResourceManagement::Resource.unmock! }

  before :each do
    ResourceManagement::Resource.delete_all
  end

  let(:service) { DomainModelServiceLayer::ServicesManager.service(:resource_management).mock! }

  let(:old_domain_id ) { '32cf6ff5-e0dd-4e8f-a264-7ebdaf3fd25b' }
  let(:old_project_id) { '07bdb713-d5db-422a-9b90-85f255b00789' }

  let(:enabled_resources) do
    enabled_services = ResourceManagement::Resource::KNOWN_SERVICES.
      select { |srv| srv[:enabled] }.map { |srv| srv[:service] }
    result = ResourceManagement::Resource::KNOWN_RESOURCES.select { |res| enabled_services.include?(res[:service]) }
    expect(result.size).to be > 0
    result
  end


  describe '#sync_all_domains' do

    it 'syncs all domains' do
      all_domains = service.driver.mock_domains_projects.keys.sort

      service.sync_all_domains

      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq(all_domains)
    end

    it 'syncs projects in known domains only for with_projects = true' do
      all_projects = service.driver.mock_domains_projects.values.map { |data| data[:projects] }.map(&:keys).flatten.sort

      service.sync_all_domains
      ResourceManagement::Resource.update_all(updated_at: 1.hour.ago) # to check which records have been updated

      service.sync_all_domains # this should be a no-op since there are no new domains/projects

      updated_projects = ResourceManagement::Resource.where('updated_at >= ?', 1.minute.ago).pluck(:project_id).uniq.sort
      expect(updated_projects).to eq([])

      service.sync_all_domains(with_projects: true)

      updated_projects = ResourceManagement::Resource.where('updated_at >= ?', 1.minute.ago).pluck(:project_id).uniq.sort
      expect(updated_projects).to eq(all_projects)
    end

    # This assertion ensures that all assertions about sync_domain and sync_project also hold for sync_all_domains.
    it 'uses #sync_domain to do the heavy lifting' do
      allow(service).to receive(:sync_domain) { |domain_id, options={}| nil } # stub

      service.sync_all_domains

      # since we stubbed the part that's doing all the work, nothing was created
      expect(ResourceManagement::Resource.count).to eq(0)
    end

    it 'cleans up data for deleted domains' do
      # simulate data from a domain that has been deleted
      enabled_resources.each do |res|
        ResourceManagement::Resource.create(
          domain_id:      old_domain_id,
          project_id:     nil,
          service:        res[:service],
          name:           res[:name],
          approved_quota: 42,
        )
        ResourceManagement::Resource.create(
          domain_id:      old_domain_id,
          project_id:     old_project_id,
          service:        res[:service],
          name:           res[:name],
          current_quota:  42,
          approved_quota: 42,
          usage:          23,
        )
      end

      service.sync_all_domains
      expect(ResourceManagement::Resource.where(domain_id: old_domain_id).count).to eq(0)
    end

  end

  describe '#sync_domain' do

    let(:domain_id) do
      domains_projects = service.driver.mock_domains_projects
      domains_projects.select { |domain_id, data| data[:projects].size > 1 }.keys.sort.first
    end
    let(:domain_projects) { service.driver.mock_domains_projects[domain_id][:projects].keys.sort }

    it 'syncs exactly this domain and its projects' do
      service.sync_domain(domain_id)
      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq([domain_id])

      created_projects = ResourceManagement::Resource.where.not(project_id: nil).pluck(:project_id).uniq.sort
      expect(created_projects).to eq(domain_projects)
    end

    it 'initializes approved_quota when called the first time' do
      service.sync_domain(domain_id)

      enabled_resources.each do |res|
        r = ResourceManagement::Resource.where(domain_id: domain_id, project_id: nil, service: res[:service], name: res[:name]).to_a
        expect(r.size).to eq(1)
        expect(r.first.approved_quota).to eq(0)
      end
    end

    it 'syncs existing projects in this domain only for with_projects = true' do
      service.sync_domain(domain_id)

      ResourceManagement::Resource.update_all(updated_at: 1.hour.ago) # to check which records have been updated

      service.sync_domain(domain_id)

      updated_records = ResourceManagement::Resource.where('updated_at >= ?', 1.minute.ago)
      expect(updated_records.size).to eq(0)

      service.sync_domain(domain_id, with_projects: true)

      updated_projects = ResourceManagement::Resource.where('updated_at >= ?', 1.minute.ago).pluck(:project_id).uniq.sort
      expect(updated_projects).to eq(domain_projects)
    end

    it 'cleans data for deleted projects' do
      # simulate data from a project that has been deleted
      enabled_resources.each do |res|
        ResourceManagement::Resource.create(
          domain_id:      domain_id,
          project_id:     old_project_id,
          service:        res[:service],
          name:           res[:name],
          current_quota:  42,
          approved_quota: 42,
          usage:          23,
        )
      end

      service.sync_domain(domain_id)
      expect(ResourceManagement::Resource.where(project_id: old_project_id).count).to eq(0)
    end

    # This assertion ensures that all assertions about sync_project also hold for sync_domain.
    it 'uses sync_project to do the heavy lifting' do
      allow(service).to receive(:sync_project) { |project_id| nil } # stub

      service.sync_domain(domain_id)

      # since we stubbed the part that's updating projects, no records should have been created for projects
      expect(ResourceManagement::Resource.where.not(project_id: nil).count).to eq(0)
    end

  end

  describe '#sync_project' do

    let(:domain_id) do
      domains_projects = service.driver.mock_domains_projects
      domains_projects.select { |domain_id, data| data[:projects].size > 1 }.keys.sort.first
    end
    let(:project_id) { service.driver.mock_domains_projects[domain_id][:projects].keys.sort.first }

    it 'touches only the given project' do
      service.sync_project(domain_id, project_id)

      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq([domain_id])
      expect(ResourceManagement::Resource.pluck(:project_id).uniq.sort).to eq([project_id])
    end

    it 'syncs all the enabled resources' do
      service.sync_project(domain_id, project_id)

      synced_resources   = ResourceManagement::Resource.pluck(:service, :name).sort
      expected_resources = enabled_resources.map { |res| [ res[:service].to_s, res[:name].to_s ] }.sort
      expect(synced_resources).to eq(expected_resources)
    end

    it 'creates missing records, but also updates existing records' do
      # pre-populate *some* resources, to check that only the missing ones are created
      enabled_resources.sample(enabled_resources.size / 2).each do |res|
        ResourceManagement::Resource.create(
          domain_id:      domain_id,
          project_id:     project_id,
          service:        res[:service],
          name:           res[:name],
          current_quota:  42,
          approved_quota: 42,
          usage:          23,
        )
      end
      ResourceManagement::Resource.update_all(updated_at: 1.hour.ago) # to check which records have been updated

      service.sync_project(domain_id, project_id)

      # all records should have been touched
      untouched_records = ResourceManagement::Resource.where('updated_at < ?', 1.minute.ago)
      expect(untouched_records.size).to eq(0)

      # each resource should have exactly one record
      enabled_resources.each do |res|
        records = ResourceManagement::Resource.where(service: res[:service], name: res[:name])
        expect(records.size).to eq(1)
      end

      # should only have scanned the enabled resources, nothing else
      expect(ResourceManagement::Resource.count).to eq(enabled_resources.size)
    end

  end

end
