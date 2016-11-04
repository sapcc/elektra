module Monitoring
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. 
    # Only put code in here that is shared across controllers.
    authorization_context 'monitoring'

    # handle api errors
    rescue_and_render_error_page [ 
      { "Core::ServiceLayer::Errors::ApiError" => { 
        title: 'API Error',
        description: -> e,_ { 
          if e.response_data 
            result = e.response_data.try('title').to_s + " - " + e.response_data.try('description').to_s
            if  result == " - "
              e
            end
          else
            e
          end
        }
      }},
      { "Excon::Error" => { 
        title: 'API Error',
        description: -> e,_ { 
          exception     = e
          exception_msg = ""
          
          endpoint      = ""
          request = exception.request
          if request 
            endpoint = " - Involved endpoint url: "+request[:scheme]+"://"+request[:host]+request[:path]
          end

          if(exception.class.name == "Excon::Error::ServiceUnavailable")
            # in that case we have no json to parse
            exception_msg = exception.response.reason_phrase+endpoint
          else
            description   = ""
            begin
              response = JSON.parse(exception.response.body)
              # monasca api error handling
              if response['title'] && response['description']
                exception_msg = response['title'] || ""
                description   = "Description: "+response['description'] || ""
              else
                # other
                reason = response.keys[0] || ""
                exception_msg = "#{reason.capitalize}"
                description = "Description: "+response[reason]['message']
              end
           rescue
              # fallback if everything goes wrong
              exception_msg = "Error - #{exception.message}"
            end
             
            unless description.empty?
              exception_msg+" - "+description+endpoint 
            else 
              exception_msg+endpoint
            end
          end
          }
        }
      }
     ]

     # Note to myself: I keep that here because I am currently not sure that the solution above will work
     # rescue_from Excon::Errors::HTTPStatusError do |exception|
     #   if(exception.class.name == "Excon::Error::ServiceUnavailable")
     #     # in that case we have no json to parse
     #     @exception_msg = exception.response.reason_phrase
     #   else
     #     begin
     #       response = JSON.parse(exception.response.body)
     #       # monasca api error handling
     #       if response['title'] && response['description']
     #         @exception_msg = response['title'] || ""
     #         @description   = response['description'] || ""
     #       else
     #         # other
     #         reason = response.keys[0] || ""
     #         @exception_msg = "#{reason.capitalize} - #{response[reason]['message']}"
     #         if response[reason]['message'] == "Invalid token" || response[reason]['message'] == "The request you have made requires authentication."
     #           @load_after_auth = request.original_url
     #           if modal?
     #             # to load modal window instantly after the logon
     #             @load_after_auth = @load_after_auth.gsub request.original_url.split('/').last, ""
     #             overlay = request.path.split('/').last
     #             @load_after_auth = @load_after_auth+"?overlay="+overlay
     #           end
     #         end
     #       end
     #     rescue
     #       # fallback if everything goes wrong
     #       @exception_msg = "Error - #{exception.message}"
     #     end
     #   end
     #   
     #   render template: '/monitoring/application/backend_error'
     # end

  end
end
