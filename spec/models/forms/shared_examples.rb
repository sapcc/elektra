shared_examples_for "a base object" do
  class_name = described_class.name.split('::').last.downcase
  
  let(:service) { double('service').as_null_object  }
  let(:forms_object) { described_class.new(service) }

  describe "required class methods" do
    subject { described_class } 
    it { should respond_to(:wrapper_for) }
  end
  
  describe "required instance methods" do
    
    subject { forms_object}
    
    it { should respond_to(:errors) }
    it { should respond_to(:model_name) }
    it { should respond_to(:to_model) }
    it { should respond_to(:to_key) }
    it { should respond_to(:to_param) }
    it { should respond_to(:to_partial_path) }
    it { should respond_to(:attributes=) }
  end

  describe "initialize" do
    it "should build a new instance of #{described_class}" do
      expect(forms_object).not_to be(nil)
    end
    
    it "should call a service find method" do
      new_forms_object = described_class.new(service, 1)
      expect(service).to have_received("find_#{class_name}").with(1)
    end
    
    it "should load model" do
      model = double("#{class_name} model").as_null_object
      allow(model).to receive_messages(id:1, name: 'test')
      allow(service).to receive("find_#{class_name}").with(1).and_return(model)
      
      new_forms_object = described_class.new(service, 1)
      expect(new_forms_object.instance_variable_get("@model")).to eq(model)
    end
  end
  
end

shared_examples_for "a wrapper for" do |wrapped_class|
  let(:service) { double('service').as_null_object  }
  let(:forms_object) { described_class.new(service) }
  
  describe "attributes" do
    subject { forms_object }
    
    wrapped_class.attributes.each do |name|
      it { should respond_to(name.to_sym) }  
    end
  end
end