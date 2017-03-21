module Monitoring
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. 
    # Only put code in here that is shared across controllers.
    authorization_context 'monitoring'

    # handle api errors
    rescue_and_render_exception_page [ 
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

  end
end
