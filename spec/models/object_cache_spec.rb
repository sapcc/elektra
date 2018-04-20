require 'spec_helper'

RSpec.describe ObjectCache, type: :model do
  let(:data) {{
    'id' => 'dsdada12345',
    'project_id' => '6789',
    'name' => 'Test',
    'cached_object_type' => 'User',
    'email' => 'xzy@test.com',
    'description' => 'Test User'
  }}

  describe '::cache_object' do
    context 'object is not cached yet' do
      it 'should add new item to table' do
        expect {
          expect(ObjectCache.cache_object(data)).not_to be(nil)
        }.to change(ObjectCache, :count).by 1
      end

      it 'should return new created item' do
        item = ObjectCache.cache_object(data)
        expect(item).not_to be(nil)
      end

      it 'should create new item' do
        ObjectCache.cache_object(data)
        item = ObjectCache.find_by_id(data['id'])
        expect(item.name).to eq(data['name'])
      end
    end

    context 'object already registered' do
      before :each do
        ObjectCache.cache_object(data)
      end

      it 'should not increase count of ObjectCache' do
        expect {
          expect(ObjectCache.cache_object(data)).not_to be(nil)
        }.to change(ObjectCache, :count).by 0
      end

      it 'should return updated item' do
        new_data = data.merge('name' => 'New Name')
        item = ObjectCache.cache_object(new_data)
        expect(item.name).to eql(new_data['name'])
      end

      it 'should update item' do
        new_data = data.merge('name' => 'New Name')
        ObjectCache.cache_object(new_data)
        item = ObjectCache.find_by_id(new_data['id'])
        expect(item.name).to eql(new_data['name'])
      end
    end
  end

  describe '::cache_objects' do
    let(:objects) {
      random_objects(100)
    }

    context 'no object is cached yet' do
      it 'should add all objets at once' do
        expect {
          ObjectCache.cache_objects(objects)
        }.to change(ObjectCache, :count).by (100)
      end
    end

    context 'some objects are already registered' do
      before :each do
        objects[0..49].each { |o| ObjectCache.cache_object(o) }
      end

      it 'should add new objets' do
        expect {
          ObjectCache.cache_objects(objects)
        }.to change(ObjectCache, :count).by (50)
      end

      it 'should add new objets at once' do
        expect(ObjectCache).to receive(:update).once
        ObjectCache.cache_objects(objects)
      end

      it 'should create records' do
        ObjectCache.cache_objects(objects)
        item = ObjectCache.find_by_id(objects[50]['id'])
        expect(item.name).to eq(objects[50]['name'])
      end

      it 'should not change the count' do
        new_records = objects[0..1].collect { |o| o['name'] = 'New Name'; o }
        expect {
          ObjectCache.cache_objects(new_records)
        }.to change(ObjectCache, :count).by 0
      end

      it 'should update records' do
        new_records = objects[0..1].collect { |o| o['name'] = 'New Name'; o }
        ObjectCache.cache_objects(new_records)
        items = ObjectCache.search(name: 'New Name')
        expect(items.length).to eq(2)
      end
    end

    context 'all objects are registered' do
      before :each do
        objects.each { |o| ObjectCache.cache_object(o) }
      end

      it 'should not add any objets' do
        expect {
          ObjectCache.cache_objects(objects)
        }.to change(ObjectCache, :count).by (0)
      end
    end
  end

  describe '::search' do
    before :each do
      random_objects(100).each { |d| ObjectCache.cache_object(d) }
    end

    it 'should find item by id' do
      item = ObjectCache.search(ObjectCache.first.id)
      expect(item).not_to be(nil)
    end

    it 'should find exactly one item by id' do
      items = ObjectCache.search(ObjectCache.first.id)
      expect(items.length).to eql(1)
    end

    it 'should find items by name' do
      items = ObjectCache.search(ObjectCache.first.name)
      expect(items.first.name).to eql(ObjectCache.first.name)
    end

    it 'should find items by project_id' do
      item = ObjectCache.where('project_id IS NOT NULL').first
      items = ObjectCache.search(item.project_id)
      expect(items.first.project_id).to eql(item.project_id)
    end

    it 'should find items by project_id' do
      item = ObjectCache.where('project_id IS NOT NULL').first
      items = ObjectCache.search(item.project_id)
      expect(items.first.project_id).to eql(item.project_id)
    end

    it 'should find items by domain_id' do
      item = ObjectCache.where('domain_id IS NOT NULL').first
      items = ObjectCache.search(item.domain_id)
      expect(items.first.domain_id).to eql(item.domain_id)
    end

    it 'should find items by given options' do
      item = ObjectCache.where('name IS NOT NULL').first
      items = ObjectCache.search(name: item.name)
      expect(items.first.name).to eql(item.name)
    end
  end

  def random_string(length = 32)
    (0...length).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def random_type
    types = ['User', 'Project', 'Port', 'Network', 'FloatingIp', 'Server']
    types[rand(types.length)]
  end

  def random_attribute
    attributes = %w[description domain_id email port_id project_id tenant_id]
    attributes[rand(attributes.length)]
  end

  def random_objects(count)
    objects = []
    count.times do
      item = {}
      item['id'] = random_string
      item['name'] = random_string(10)
      item['cached_object_type'] = random_type
      5.times { item[random_attribute] = random_string(15) }
      objects << item
    end
    objects
  end
end
