require "spec_helper"

describe ApiLookup do
  let(:dummy_class) { Class.new { include ApiLookup } }
  let(:dummy) { dummy_class.new }

  describe "api_search" do
    before :each do
      stub_const(
        "ApiLookup::SERVICE_METHOD_MAP",
        "test_object" => [
          "test_service",
          {method_name: 'find', params:[":term"]},
          {method_name: 'all', params: [{name: ":term", param: true}]},
        ],
      )
    end

    let(:service_manager) { double("service_manager").as_null_object }

    context "service exists" do
      before :each do
        @service = double("service").as_null_object
        allow(service_manager).to receive(:respond_to?).with(
          "test_service",
        ).and_return(true)
        allow(service_manager).to receive(:send).with(
          "test_service",
        ).and_return(@service)
      end

      context "first method returns results" do
        before :each do
          allow(@service).to receive(:find).with("test").and_return(
            double("test_object"),
          )
        end

        it "should return on find method" do
          expect(@service).to receive(:find).with("test")
          expect(@service).not_to receive(:all)
          dummy.api_search(service_manager, "test_object", "test")
        end
      end

      context "last method returns results" do
        before :each do
          allow(@service).to receive(:find).with("test").and_return(nil)
        end

        it "should return on find method" do
          expect(@service).to receive(:find).with("test")
          expect(@service).to receive(:all).with({name: "test", param: true})
          dummy.api_search(service_manager, "test_object", "test")
        end
      end
    end

    context "service does not exist" do
      before :each do
        allow(service_manager).to receive(:respond_to?).with(
          "test_service",
        ).and_return(false)
      end

      it "raises service not found error" do
        expect do
          dummy.api_search(service_manager, "test_object", "test")
        end.to raise_error StandardError,
                    "Service test_service could not be found."
      end
    end
  end

  describe "service_and_methods" do
    it "raises object type not supported error" do
      expect do
        dummy.service_and_methods("xyz")
      end.to raise_error StandardError, "xyz is not supported."
    end

    ApiLookup::SERVICE_METHOD_MAP.each do |key, values|
      describe key do
        it "returns the service" do
          service, _methods = dummy.service_and_methods(key)
          expect(service).to eq(values.first)
        end

        it "returns service is a String" do
          service, _methods = dummy.service_and_methods(key)
          expect(service).to be_a(String)
        end

        it "returns service methods as Array" do
          _service, methods = dummy.service_and_methods(key)
          expect(methods).to be_a(Array)
        end

        it "returns service methods" do
          _service, methods = dummy.service_and_methods(key)
          expect(methods).to eq(values[1..-1])
        end

        it "count of methods should be one less" do
          _service, methods = dummy.service_and_methods(key)
          expect(methods.length).to eq(values.length - 1)
        end
      end
    end
  end
end
