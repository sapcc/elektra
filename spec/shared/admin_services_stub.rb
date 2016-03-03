def stub_admin_services(&block)
  allow(Core::ServiceUser::Base).to receive(:load).and_return(double("service_user").as_null_object)
  allow_any_instance_of(Dashboard::OnboardingService).to receive(:new_user?).and_return(false)
  
  service_user = double('service_user').as_null_object

  allow(service_user).to receive(:domain_id).and_return(AuthenticationStub.test_token["user"]["domain"]["id"])
  allow(service_user).to receive(:domain_name).and_return(AuthenticationStub.test_token["user"]["domain"]["name"])
  allow(::Core::ServiceUser::Base).to receive(:load).and_return(service_user)
  
  block.call(service_user) if block_given?
end