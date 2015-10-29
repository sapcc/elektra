require 'spec_helper'

RSpec.describe Docs::PagesController, :type => :routing do
  routes { Docs::Engine.routes }

  it "routes to the start page" do
    expect(:get => docs_path).
      to route_to(controller: "docs/pages", action: "show", id: 'start')
  end
end