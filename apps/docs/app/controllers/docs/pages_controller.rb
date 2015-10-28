module Docs
  class PagesController < Core::ScopeController
    def show
      render template: "/docs/pages/#{params[:id]}"
    end                  
  end
end
