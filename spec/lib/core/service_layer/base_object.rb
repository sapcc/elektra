require 'spec_helper'

describe Core::ServiceLayer::Model do
  before :each do
    @driver = double('driver').as_null_object
    @base_object = Core::ServiceLayer::Model.new(@driver)
  end
  
  describe 'model_name' do
    it "should respond to moedl_name" do
      expect(@base_object).to respond_to(:model_name)
    end

    it "should respond to params_key" do
      expect(@base_object.model_name).to respond_to(:param_key)
    end
    
    it "should respond to route_key" do
      expect(@base_object.model_name).to respond_to(:route_key)
    end
  end
  
  describe 'errors' do
    it 'responds to errors' do
      expect(@base_object).to respond_to(:errors)
    end
    
    it 'returns an errors object' do
      expect(@base_object.errors).to be_kind_of(ActiveModel::Errors)
    end
  end
  
  describe 'attributes' do
    it 'responds to attributes' do
      expect(@base_object).to respond_to(:attributes)
    end
    
    it 'sets attributes' do
      @base_object.attributes=({'test'=> 'test'})
      expect(@base_object.attributes).to eq({'test'=>'test'})
    end
        
    context 'params contain id attribute' do    
      before :each do
        expect(@base_object.id).to eq(nil)
      end
      
      it 'excludes id attribute' do    
        @base_object.attributes=({'id'=>1,'test'=> 'test'})  
        expect(@base_object.attributes).to eq({'test'=>'test'})
      end
      
      it 'sets id from params' do
        @base_object.attributes=({'id'=>1,'test'=> 'test'})  
        expect(@base_object.id).to eq(1)
      end
    end
    
    context 'method missing' do
      it 'reads a value from attributes' do
        expect(@base_object).not_to respond_to(:test)
        @base_object.test='not nil'
        expect(@base_object).to respond_to(:test)
      end
    end
    
  end
  
  describe 'create_attributes' do
    before :each do
      @base_object.attributes={'a'=>'test','b'=>'test'}
    end
    
    it 'returns attributes' do
      expect(@base_object.create_attributes).to eq({'a'=>'test','b'=>'test'})  
    end
  end
  
  describe 'update_attributes' do
    before :each do
      @base_object.attributes={'a'=>'test','b'=>'test'}
    end
    
    it 'returns attributes' do
      expect(@base_object.update_attributes).to eq({'a'=>'test','b'=>'test'})  
    end
  end
  
  describe '::initialize' do
    it 'executes after_initialize callback' do
      expect_any_instance_of(Core::ServiceLayer::Model).to receive(:after_initialize)
      Core::ServiceLayer::Model.new(@driver)
    end
        
    context 'no params given' do
      it 'creates a new empty base object' do
        o = Core::ServiceLayer::Model.new(@driver)
        expect(o.attributes).to eq({})
      end
    end
    
    context 'params given' do
      it 'creates a new base object' do
        o = Core::ServiceLayer::Model.new(@driver, {'a' => 'test'})
        expect(o.attributes).to eq({'a'=>'test'})
      end
      
      it 'sets id from params' do
        o = Core::ServiceLayer::Model.new(@driver, {'id'=>1,'a' => 'test'})
        expect(o.id).to eq(1)
      end
    end
  end

  describe 'id' do
    it 'responds to id' do
      expect(@base_object).to respond_to(:id)
    end
  end 
  
  describe '::requires' do
    it 'raises an error if attribute missing' do
      expect{
        @base_object.requires(:test)
      }.to raise_error
    end
    
    it "raises an 'id missing' error" do
      expect{
        @base_object.requires(:id)
      }.to raise_error
    end
    
    it "no error raised" do
      o = Core::ServiceLayer::Model.new(@driver, {'id'=>1,'attr1' => 'test'})
      expect{
        o.requires(:id,:attr1)
      }.not_to raise_error
    end
  end

  describe 'save' do
    context 'id is nil' do
      before :each do
        @o = Core::ServiceLayer::Model.new(@driver)
      end
      
      it 'calls create method' do
        expect(@o).to receive(:perform_create)
        expect(@o).not_to receive(:perform_update)
        @o.save
      end
    end
    
    context 'id is not nil' do
      before :each do
        @o = Core::ServiceLayer::Model.new(@driver, {'id'=>1})
      end
      it 'calls update method' do
        expect(@o).to receive(:perform_update)
        expect(@o).not_to receive(:perform_create)
        @o.save
      end
      
      it 'should remember id' do
        expect(@o.id).to eq(1)
        @o.attributes={'a1'=>'test1'}
        expect(@o.id).to eq(1)
      end
    end
    
    it 'executes before_save callback' do
      expect(@base_object).to receive(:before_save)
      @base_object.save
    end
    
    it 'executes after_save callback' do
      expect(@base_object).to receive(:after_save)
      @base_object.save
    end
    
  end
  
  describe 'destroy' do
    context 'id is nil' do
      it 'raises an error' do
        expect{
          expect(@base_object.id).to eq(nil)
          @base_object.destroy
        }.to raise_error
      end
    end
    
    it 'execute a before_destroy callback' do
      
    end
  end
  
  describe 'callbacks' do
    subject{ @base_object}
    it { is_expected.to respond_to(:before_save) }
    it { is_expected.to respond_to(:before_destroy) }
    it { is_expected.to respond_to(:before_create) }
    it { is_expected.to respond_to(:after_initialize) }
    it { is_expected.to respond_to(:after_create) }
    it { is_expected.to respond_to(:after_save) }
  end
  
  describe 'created_at' do
    context 'attributes are empty' do
      it 'returns nil' do
        expect(@base_object.created_at).to be(nil)
      end
    end
    
    context 'attributes contains a created date string' do
      it 'returns a date object' do
        now = Time.now.to_s
        @base_object.attributes={'created'=>now}
        expect(@base_object.created_at).to eq(now)
      end
    end
    
    context 'attributes contains a created_at date string' do
      it 'returns a date object' do
        now = Time.now.to_s
        @base_object.attributes={'created_at'=>now}
        expect(@base_object.created_at).to eq(now)
      end
    end
  end
  
  describe 'updated_at' do
    context 'attributes are empty' do
      it 'returns nil' do
        expect(@base_object.created_at).to be(nil)
      end
    end
    
    context 'attributes contains a update date string' do
      it 'returns a date object' do
        now = Time.now.to_s
        @base_object.attributes={'updated'=>now}
        expect(@base_object.updated_at).to eq(now)
      end
    end
    
    context 'attributes contains a updated_at date string' do
      it 'returns a date object' do
        now = Time.now.to_s
        @base_object.attributes={'updated_at'=>now}
        expect(@base_object.updated_at).to eq(now)
      end
    end
  end

  describe 'write' do
    it 'writes a value to attributes' do
      @base_object.write('hello','world')
      @base_object.write(:attr1,'test')
      expect(@base_object.hello).to eq('world')
      expect(@base_object.attr1).to eq('test')
    end
  end
  
  describe 'read' do
    it 'reads a value from attributes' do
      @base_object.attributes={'a1'=>'test1',a2: 'test2'}
      expect(@base_object.read(:a1)).to eq('test1')
      expect(@base_object.read('a2')).to eq('test2')
    end
  end  

  describe 'pretty_attributes' do
    it 'returns an json string' do
      @base_object.attributes={'a1'=>'test1',a2: 'test2'}
      expect(@base_object.pretty_attributes).to be_kind_of(String)
    end
  end

  describe 'create' do
    it "calls driver's create method" do
      @base_object.attributes={'a1'=>'test1',a2: 'test2'}
      expect(@driver).to receive(:create_base_object).with({a1: 'test1',a2: 'test2'}) 
      @base_object.save
    end
  end
  
  describe 'update' do
    it "calls driver's update method" do
      @base_object.attributes={'id'=>1,'a1'=>'test1',a2: 'test2'}
      expect(@driver).to receive(:update_base_object).with(1,{a1: 'test1',a2: 'test2'}) 
      @base_object.save  
    end   
  end
  
  describe 'attribute_to_object' do
    it 'creates an object from attributes' do
      @base_object.attributes={'subobject'=>{a1:'test1',a2: 'test2'}}
      subobject = @base_object.attribute_to_object(:subobject,Core::ServiceLayer::Model)
      expect(subobject).to be_kind_of(Core::ServiceLayer::Model)
      expect(subobject.a1).to eq('test1')
    end
  end
  
  describe 'handle_api_error' do
    context 'excon error' do
      #....
    end
  end


end
