def stub_admin_services
  allow(Core::ServiceUser::Base).to receive(:load).and_return(double("service_user").as_null_object)
  allow_any_instance_of(Dashboard::OnboardingService).to receive(:new_user?).and_return(false)
end