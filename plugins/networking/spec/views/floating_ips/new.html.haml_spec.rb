require 'spec_helper'

RSpec.describe "networking/floating_ips/new.html.haml", type: :view do
  default_params = {domain_id: AuthenticationStub.domain_id, project_id: AuthenticationStub.project_id}

  before do
    allow(view).to receive(:modal?).and_return(false)
    assign(:scoped_domain_fid, default_params[:domain_id])
    assign(:floating_ip, Networking::FloatingIp.new(nil))
    assign(:floating_networks, [])
  end

  it "displays the subnet select box" do
    render

    expect(rendered).to match /id="floating_ip_floating_subnet_id"/
  end

end
