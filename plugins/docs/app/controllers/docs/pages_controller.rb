module Docs
  class PagesController < ScopeController
    def show
      render template: "/docs/pages/#{params[:id]}"
    end                  
  end
end
