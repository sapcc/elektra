require 'spec_helper'

RSpec.describe ServiceLayer::ResourceManagementService do

  class ServicesIdentityMock
    @@domains = nil

    def initialize
      unless @@domains
        dFooID = SecureRandom.uuid
        dQuxID = SecureRandom.uuid
        @@domains = [
          Core::ServiceLayer::Model.new(nil, { id: dFooID, name: 'foodomain' }),
          Core::ServiceLayer::Model.new(nil, { id: dQuxID, name: 'quxdomain' }),
        ]
        @@projects = [
          Core::ServiceLayer::Model.new(nil, { id: SecureRandom.uuid, name: 'fooproject', domain_id: dFooID }),
          Core::ServiceLayer::Model.new(nil, { id: SecureRandom.uuid, name: 'barproject', domain_id: dFooID }),
          Core::ServiceLayer::Model.new(nil, { id: SecureRandom.uuid, name: 'quxproject', domain_id: dQuxID }),
        ]
      end
    end

    def domains
      return @@domains
    end

    def projects(filter={})
      if filter.has_key?(:domain_id)
        return @@projects.select { |p| p.domain_id == filter[:domain_id] }
      else
        return @@projects.clone
      end
    end

    def find_domain(id)
      return @@domains.find { |d| d.id == id }
    end

    def find_project(id)
      return @@projects.find { |p| p.id == id }
    end
  end

  before(:all) { ResourceManagement::ServiceConfig.mock!   }
  after (:all) { ResourceManagement::ServiceConfig.unmock! }

  before :each do
    ResourceManagement::Resource.delete_all
  end

  let(:service) { Core::ServiceLayer::ServicesManager.service(:resource_management).mock!(ServicesIdentityMock.new) }

  let(:old_domain_id ) { SecureRandom.uuid }
  let(:old_project_id) { SecureRandom.uuid }

  let(:enabled_resources) do
    result = ResourceManagement::ResourceConfig.all
    expect(result.size).to be > 0
    result
  end


  describe '#sync_all_domains' do

    it 'syncs all domains and all projects within the domains' do
      all_domains = service.services_identity.domains.map(&:id).sort
      all_projects = service.services_identity.projects.map(&:id).sort

      service.sync_all_domains

      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq(all_domains)
      expect(ResourceManagement::Resource.where.not(project_id: nil).pluck(:project_id).uniq.sort).to eq(all_projects)
    end

    # This assertion ensures that all assertions about sync_domain and sync_project also hold for sync_all_domains.
    it 'uses #sync_domain to do the heavy lifting' do
      allow(service).to receive(:sync_domain) { |domain_id, options={}| nil } # stub

      service.sync_all_domains

      # since we stubbed the part that's doing all the work, nothing was
      # created (except for the domain quotas)
      expect(ResourceManagement::Resource.count).to eq(service.services_identity.domains.count * ResourceManagement::ResourceConfig.all.count)
    end

    context 'when talking to a standard Keystone' do
      before(:each) { ENV['HAS_KEYSTONE_ROUTER'] = '0' }

      it 'cleans up data for deleted domains' do
        # simulate data from a domain that has been deleted
        enabled_resources.each do |res|
          ResourceManagement::Resource.create(
            domain_id:      old_domain_id,
            project_id:     nil,
            service:        res.service_name,
            name:           res.name,
            approved_quota: 42,
          )
          ResourceManagement::Resource.create(
            domain_id:      old_domain_id,
            project_id:     old_project_id,
            service:        res.service_name,
            name:           res.name,
            current_quota:  42,
            approved_quota: 42,
            usage:          23,
          )
        end

        service.sync_all_domains
        expect(ResourceManagement::Resource.where(domain_id: old_domain_id).count).to eq(0)
      end

    end

    context 'when talking to a Keystone router' do
      before(:each) { ENV['HAS_KEYSTONE_ROUTER'] = '1' }

      it 'retains data for a domain not included in the domain listing' do
        # simulate data from a domain that has been deleted
        enabled_resources.each do |res|
          ResourceManagement::Resource.create(
            domain_id:      old_domain_id,
            project_id:     nil,
            service:        res.service_name,
            name:           res.name,
            approved_quota: 42,
          )
          ResourceManagement::Resource.create(
            domain_id:      old_domain_id,
            project_id:     old_project_id,
            service:        res.service_name,
            name:           res.name,
            current_quota:  42,
            approved_quota: 42,
            usage:          23,
          )
        end

        service.sync_all_domains
        expect(ResourceManagement::Resource.where(domain_id: old_domain_id, project_id: nil).count).to eq(enabled_resources.count)
        expect(ResourceManagement::Resource.where(domain_id: old_domain_id, project_id: old_project_id).count).to eq(enabled_resources.count)
      end

    end

  end

  describe '#sync_domain' do

    let(:domain_id)       { service.services_identity.domains.first.id }
    let(:domain_projects) { service.services_identity.projects(domain_id: domain_id).map(&:id).sort }

    it 'syncs exactly this domain and its projects' do
      service.sync_domain(domain_id)
      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq([domain_id])

      created_projects = ResourceManagement::Resource.where.not(project_id: nil).pluck(:project_id).uniq.sort
      expect(created_projects).to eq(domain_projects)

      ResourceManagement::Resource.update_all(updated_at: 1.hour.ago) # to check which records have been updated

      service.sync_domain(domain_id)

      updated_projects = ResourceManagement::Resource.where('project_id IS NOT NULL AND updated_at >= ?', 1.minute.ago).pluck(:project_id).uniq.sort
      expect(updated_projects).to eq(domain_projects)
    end

    it 'initializes approved_quota when called the first time' do
      service.sync_domain(domain_id)

      enabled_resources.each do |res|
        r = ResourceManagement::Resource.where(domain_id: domain_id, project_id: nil, service: res.service_name, name: res.name).to_a
        expect(r.size).to eq(1)
        expect(r.first.approved_quota).to eq(0)
      end
    end

    it 'cleans data for deleted projects' do
      # simulate data from a project that has been deleted
      enabled_resources.each do |res|
        ResourceManagement::Resource.create(
          domain_id:      domain_id,
          project_id:     old_project_id,
          service:        res.service_name,
          name:           res.name,
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
      # (except for the "needs_sync" dummy records)
      expect(ResourceManagement::Resource.where.not(project_id: nil).count).to eq(domain_projects.count)
    end

  end

  describe '#sync_project' do

    let(:domain_id)  { service.services_identity.domains.first.id }
    let(:project_id) { service.services_identity.projects(domain_id: domain_id).first.id }

    it 'touches only the given project' do
      service.sync_project(domain_id, project_id)

      expect(ResourceManagement::Resource.pluck(:domain_id).uniq.sort).to eq([domain_id])
      expect(ResourceManagement::Resource.pluck(:project_id).uniq.sort).to eq([project_id])
    end

    it 'syncs all the enabled resources' do
      service.sync_project(domain_id, project_id)

      synced_resources   = ResourceManagement::Resource.pluck(:service, :name).sort
      expected_resources = enabled_resources.map { |res| [ res.service_name.to_s, res.name.to_s ] }.sort
      expect(synced_resources).to eq(expected_resources)
    end

    it 'enforces default quotas on newly discovered projects that lack one', :focus => true  do
      # create domain resource for capacity
      ResourceManagement::Resource.create(domain_id:domain_id, name:"capacity", service:"mock_service", default_quota:1 << 30)
      # override the mock driver's usual logic of returning a random non-zero quota
      service.driver.set_project_quota(domain_id, project_id, :mock_service, { capacity: -1 })
      service.sync_project(domain_id, project_id)

      # the default quota should be visible in the resource record
      resource = ResourceManagement::Resource.find_by(name: :capacity, domain_id:domain_id, project_id:project_id)
      default  = resource.approved_quota
      expect(default).to be >= 0
      expect(resource.current_quota).to eq(default)

      # the default quota should also be set in the driver
      quota = service.driver.query_project_quota(domain_id, project_id, :mock_service)
      expect(quota).to include(capacity: default)
    end

    it 'creates missing records, but also updates existing records' do
      # pre-populate *some* resources, to check that only the missing ones are created
      enabled_resources.sample(enabled_resources.size / 2).each do |res|
        ResourceManagement::Resource.create(
          domain_id:      domain_id,
          project_id:     project_id,
          service:        res.service_name,
          name:           res.name,
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
        records = ResourceManagement::Resource.where(service: res.service_name, name: res.name)
        expect(records.size).to eq(1)
      end

      # should only have scanned the enabled resources, nothing else
      expect(ResourceManagement::Resource.count).to eq(enabled_resources.size)
    end

  end

end
