def stub_admin_services(&block)
  region = (AuthenticationStub.test_token["catalog"].first["endpoints"].first["region"] || AuthenticationStub.test_token["catalog"].first["endpoints"].first["region_id"])
  allow(Core).to receive(:locate_region).and_return(region)
  allow_any_instance_of(Dashboard::OnboardingService).to receive(:new_user?).and_return(false)
  
  service_user = double('service_user').as_null_object

  allow(service_user).to receive(:domain_id).and_return(AuthenticationStub.test_token["user"]["domain"]["id"])
  allow(service_user).to receive(:domain_name).and_return(AuthenticationStub.test_token["user"]["domain"]["name"])
  allow(::Core::ServiceUser::Base).to receive(:load).and_return(service_user)
  
  block.call(service_user) if block_given?
end