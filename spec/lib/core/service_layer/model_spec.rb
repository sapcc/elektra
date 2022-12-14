require "spec_helper"

describe Core::ServiceLayer::Model do
  before :each do
    # @service = double('service').as_null_object
    @elektron = double("elektron").as_null_object
    @service = Core::ServiceLayer::Service.new(@elektron)
    allow(@service).to receive(:create_model).and_return("a" => "b")
    allow(@service).to receive(:update_model).and_return("a" => "b")
    @model = Core::ServiceLayer::Model.new(@service)
  end

  describe "model_name" do
    it "should respond to moedl_name" do
      expect(@model).to respond_to(:model_name)
    end

    it "should respond to params_key" do
      expect(@model.model_name).to respond_to(:param_key)
    end

    it "should respond to route_key" do
      expect(@model.model_name).to respond_to(:route_key)
    end
  end

  describe "errors" do
    it "responds to errors" do
      expect(@model).to respond_to(:errors)
    end

    it "returns an errors object" do
      expect(@model.errors).to be_kind_of(ActiveModel::Errors)
    end
  end

  describe "attributes" do
    it "should trim all attributes" do
      model =
        Core::ServiceLayer::Model.new(
          @service,
          "a" => " test a ",
          "b" => "  test b  ",
        )
      model.valid?
      expect(model.a).to eq("test a")
      expect(model.b).to eq("test b")
    end

    it "responds to attributes" do
      expect(@model).to respond_to(:attributes)
    end

    it "sets attributes" do
      @model.attributes = ({ "test" => "test" })
      expect(@model.attributes).to eq("test" => "test", "id" => nil)
    end

    context "params contain id attribute" do
      before :each do
        expect(@model.id).to eq(nil)
      end

      it "excludes id attribute" do
        @model.attributes = ({ "id" => 1, "test" => "test" })
        expect(@model.attributes).to eq("test" => "test", "id" => 1)
      end

      it "sets id from params" do
        @model.attributes = ({ "id" => 1, "test" => "test" })
        expect(@model.id).to eq(1)
      end
    end

    context "method missing" do
      it "reads a value from attributes" do
        expect(@model).not_to respond_to(:test)
        @model.test = "not nil"
        expect(@model).to respond_to(:test)
      end
    end
  end

  describe "attributes_for_create" do
    before :each do
      @model.attributes = { "a" => "test", "b" => "test" }
    end

    it "returns attributes" do
      expect(@model.attributes_for_create).to eq("a" => "test", "b" => "test")
    end
  end

  describe "attributes_for_update" do
    before :each do
      @model.attributes = { "a" => "test", "b" => "test" }
    end

    it "returns attributes" do
      expect(@model.attributes_for_update).to eq("a" => "test", "b" => "test")
    end
  end

  describe "::initialize" do
    it "executes after_initialize callback" do
      expect_any_instance_of(Core::ServiceLayer::Model).to receive(
        :after_initialize,
      )
      Core::ServiceLayer::Model.new(@service)
    end

    context "no params given" do
      it "creates a new empty base object" do
        o = Core::ServiceLayer::Model.new(@service)
        expect(o.attributes).to eq("id" => nil)
      end
    end

    context "params given" do
      it "creates a new base object" do
        o = Core::ServiceLayer::Model.new(@service, "a" => "test")
        expect(o.attributes).to eq("a" => "test", "id" => nil)
      end

      it "sets id from params" do
        o = Core::ServiceLayer::Model.new(@service, "id" => 1, "a" => "test")
        expect(o.id).to eq(1)
      end
    end
  end

  describe "id" do
    it "responds to id" do
      expect(@model).to respond_to(:id)
    end
  end

  describe "::requires" do
    it "raises an error if attribute missing" do
      expect do @model.requires(:test) end.to raise_error(ArgumentError)
    end

    it "raises an 'id missing' error" do
      expect do @model.requires(:id) end.to raise_error(
        Core::ServiceLayer::Model::MissingAttributeError,
      )
    end

    it "no error raised" do
      o = Core::ServiceLayer::Model.new(@service, "id" => 1, "attr1" => "test")
      expect do o.requires(:id, :attr1) end.not_to raise_error
    end
  end

  describe "save" do
    context "id is nil" do
      before :each do
        @model_without_id = Core::ServiceLayer::Model.new(@service)
      end

      it "calls create method" do
        expect(@model_without_id).to receive(:perform_create)
        expect(@model_without_id).not_to receive(:perform_update)
        @model_without_id.save
      end
    end

    context "id is not nil" do
      before :each do
        @model_with_id = Core::ServiceLayer::Model.new(@service, "id" => 1)
      end
      it "calls update method" do
        expect(@model_with_id).to receive(:perform_update)
        expect(@model_with_id).not_to receive(:perform_create)
        @model_with_id.save
      end

      it "should remember id" do
        expect(@model_with_id.id).to eq(1)
        @model_with_id.attributes = { "a1" => "test1" }
        expect(@model_with_id.id).to eq(1)
      end
    end

    it "executes before_save callback" do
      expect(@model).to receive(:before_save)
      @model.save
    end

    it "executes after_save callback" do
      expect(@model).to receive(:after_save)
      @model.save
    end
  end

  describe "update" do
    let(:model) { Core::ServiceLayer::Model.new(@service, "id" => 1) }

    it "calls save method" do
      expect(model).to receive(:save)
      model.update(foo: 23, bar: 42)
    end

    it "updates attributes" do
      model.attributes = { foo: 0, bar: 0 }
      expect(@service).to receive(:update_model).and_return(nil)
      model.update(foo: 23, bar: 42)
      expect(model.foo).to eq(23)
      expect(model.bar).to eq(42)
    end

    it "does not touch existing attributes unless explicitly instructed to" do
      model.attributes = { foo: 23 }
      expect(@service).to receive(:update_model).and_return(nil)
      model.update(bar: 42)
      expect(model.foo).to eq(23)
    end
  end

  describe "destroy" do
    context "id is nil" do
      it "raises an error" do
        expect do
          expect(@model.id).to eq(nil)
          @model.destroy
        end.to raise_error(Core::ServiceLayer::Model::MissingAttributeError)
      end
    end

    it "execute a before_destroy callback" do
    end
  end

  describe "callbacks" do
    subject { @model }
    it { is_expected.to respond_to(:before_save) }
    it { is_expected.to respond_to(:before_destroy) }
    it { is_expected.to respond_to(:before_create) }
    it { is_expected.to respond_to(:after_initialize) }
    it { is_expected.to respond_to(:after_create) }
    it { is_expected.to respond_to(:after_save) }
  end

  describe "created_at" do
    context "attributes are empty" do
      it "returns nil" do
        expect(@model.created_at).to be(nil)
      end
    end

    context "attributes contains a created date string" do
      it "returns a date object" do
        now = Time.now.to_s
        @model.attributes = { "created" => now }
        expect(@model.created_at).to eq(now)
      end
    end

    context "attributes contains a created_at date string" do
      it "returns a date object" do
        now = Time.now.to_s
        @model.attributes = { "created_at" => now }
        expect(@model.created_at).to eq(now)
      end
    end
  end

  describe "updated_at" do
    context "attributes are empty" do
      it "returns nil" do
        expect(@model.created_at).to be(nil)
      end
    end

    context "attributes contains a update date string" do
      it "returns a date object" do
        now = Time.now.to_s
        @model.attributes = { "updated" => now }
        expect(@model.updated_at).to eq(now)
      end
    end

    context "attributes contains a updated_at date string" do
      it "returns a date object" do
        now = Time.now.to_s
        @model.attributes = { "updated_at" => now }
        expect(@model.updated_at).to eq(now)
      end
    end
  end

  describe "write" do
    it "writes a value to attributes" do
      @model.write("hello", "world")
      @model.write(:attr1, "test")
      expect(@model.hello).to eq("world")
      expect(@model.attr1).to eq("test")
    end
  end

  describe "read" do
    it "reads a value from attributes" do
      @model.attributes = { "a1" => "test1", :a2 => "test2" }
      expect(@model.read(:a1)).to eq("test1")
      expect(@model.read("a2")).to eq("test2")
    end
  end

  describe "pretty_attributes" do
    it "returns an json string" do
      @model.attributes = { "a1" => "test1", :a2 => "test2" }
      expect(@model.pretty_attributes).to be_kind_of(String)
    end
  end

  describe "create" do
    it "calls driver's create method" do
      @model.attributes = { "a1" => "test1", :a2 => "test2" }
      expect(@service).to receive(:create_model).with(a1: "test1", a2: "test2")
      @model.save
    end
  end

  describe "update" do
    it "calls driver's update method" do
      @model.attributes = { "id" => 1, "a1" => "test1", :a2 => "test2" }
      expect(@service).to receive(:update_model).with(
        1,
        a1: "test1",
        a2: "test2",
      )
      @model.save
    end
  end

  describe "attribute_to_object" do
    it "creates an object from attributes" do
      @model.attributes = { "subobject" => { a1: "test1", a2: "test2" } }
      subobject =
        @model.attribute_to_object(:subobject, Core::ServiceLayer::Model)
      expect(subobject).to be_kind_of(Core::ServiceLayer::Model)
      expect(subobject.a1).to eq("test1")
    end
  end

  describe "handle_api_error" do
    context "excon error" do
      # ....
    end
  end
end
