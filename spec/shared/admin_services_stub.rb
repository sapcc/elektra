def stub_admin_services
  admin_identity = double('admin_identity_service_driver').as_null_object
  identity_driver = double('identity_service_driver').as_null_object

  allow(Admin::IdentityService).to receive(:admin_identity).and_return(admin_identity)
  allow(Admin::OnboardingService).to receive(:new_user?).and_return(false)
end