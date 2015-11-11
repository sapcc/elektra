require 'spec_helper'

RSpec.describe Docs::PagesController, :type => :routing do
  routes { Docs::Engine.routes }

  it "routes to the start page" do
    expect(:get => "/").to route_to(controller: "docs/pages", action: "show", id: 'start')
  end
  
  it "routes to a page" do
    expect(:get => "/doc1").to route_to(controller: "docs/pages", action: "show", id: 'doc1')
  end
end