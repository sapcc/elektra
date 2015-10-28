require 'spec_helper'

describe BootInquirer do
  paths = ["apps/compute", "apps/core", "apps/docs", "apps/image", "apps/network"]
  apps = paths.collect{|path| BootInquirer::App.new(path,path.gsub('apps/',''))}
  
  before :each do
    BootInquirer.instance_variable_set(:@apps_path, 'apps')
    BootInquirer.instance_variable_set(:@available_apps, [])
    allow(BootInquirer).to receive(:gemspec).and_return true
  end
  
  describe '::app_available?' do
    before :each do
      BootInquirer.instance_variable_set(:@available_apps, apps)
    end
    
    it "returns true" do
      expect(BootInquirer.app_available?('compute')).to eq(true)
    end
    
    it "returns false" do
      expect(BootInquirer.app_available?('some_app')).to eq(false)
    end
  end
  
  describe '::apps_path' do
    it "returns default path" do
      expect(BootInquirer.apps_path).to eq('apps')
    end  
    
    it "returns new path" do
      BootInquirer.apps_path='plugins'
      expect(BootInquirer.apps_path).to eq('plugins')
    end
  end
  
  describe '::load_apps' do
    before :each do
      allow(BootInquirer).to receive(:all_apps_paths).and_return(paths)
    end
    
    it "load all apps" do
      BootInquirer.load_apps
      expect(BootInquirer.available_apps.count).to eq(paths.count)
    end

    it "load only specified apps" do
      BootInquirer.load_apps only: ['compute','network']
      expect(BootInquirer.available_apps.count).to eq(3)
      expect(BootInquirer.available_apps.collect{|app|app.name}).to eq(['compute','core','network'])
    end
    
    it "load all but excepted apps" do
      BootInquirer.load_apps except: ['compute','network']
      expect(BootInquirer.available_apps.count).to eq(apps.count-2)
      expect(BootInquirer.available_apps.collect{|app|app.name}).to eq(['core','docs','image'])
    end
    
    it "load all but excepted apps, ignore core" do
      BootInquirer.load_apps except: ['core','compute','network']
      expect(BootInquirer.available_apps.count).to eq(apps.count-2)
      expect(BootInquirer.available_apps.collect{|app|app.name}).to eq(['core','docs','image'])
    end
    
  end 
  
  
  describe '::app_available?' do
    it "returns false" do
      BootInquirer.load_apps(only:['core'])
      expect(BootInquirer.app_available?('compute')).to eq(false)
    end
    
    it "returns true" do
      BootInquirer.load_apps(only:['compute'])
      expect(BootInquirer.app_available?('compute')).to eq(true)
    end
  end

end
