class OsApiController < ::AjaxController

  # Example how to use in browser
  # fetch("os-api/SERVICE_NAME/SERVICE_PATH?headers=HEADERS_AS_JSON")

  # This method implements a reverse proxy to openstack API
  def reverse_proxy 
    # get http method from request
    method = request.method.downcase
    # get path from request
    path = params[:path]
    # we remove the first part of path. It is the openstack service name
    path_tokens = path.split("/")
    service_name = path_tokens.shift
    # the rest is the current path
    path = path_tokens.join("/")

    # byebug
    # headers are provided as a parameter as JSON string. So we have to parse it.
    headers = begin 
      JSON.parse(params[:headers]) 
    rescue StandardError => e
      Rails.logger.error("\033[31m\033[1mOSApiController: Could not parse headers parameter\033[0m")
      pp e
      {}  
    end
    # get api client for the given service name
    service = services.os_api.service(service_name)

    # filter the relevant params for the api client
    elektronParams = {}
    params.each do |k,v| 
      if !["domain_id","project_id","controller","action","path","headers"].include?(k)
        elektronParams[k] = v
      end
    end 
    
    # call the openstack api endpoint with given path, params and headers
    # for http methods POST, PUT, PATCH we have to consider the body parameter
    response = if ["post","put","patch"].include?(method)
      body = JSON.parse(request.body.read )
      service.public_send(method,path,body,elektronParams, headers: headers).body      
    else
      # GET, HEAD, DELETE case
      service.public_send(method,path, elektronParams, headers: headers).body      
    end
    
    # byebug
    # render response as json
    render json: response
  end
end