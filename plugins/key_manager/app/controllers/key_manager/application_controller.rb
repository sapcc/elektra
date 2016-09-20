module KeyManager

  class ApplicationController < ::DashboardController
    rescue_and_render_error_page [
      {
       "KeyManager::ApiError" => {
         header_title: "Monsoon Key-Manager",
         title: -> e, c { e.title},
         description: -> e, c { e.description},
         details: -> e, c { e.details.html_safe}
       }
      }
     ]

     private

     def experimental
       true
     end


  end

end
