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
    path += ".#{params[:format]}" if params[:format]

    headers = {"Content-Type" => request.headers["Content-Type"] || "application/json"}
    request.headers.each do |name,value| 
      if name.start_with?("HTTP_OS_API") 
        headers[name.gsub("HTTP_OS_API_","").gsub("_","-")] = value 
      end
    end

    # byebug
    
    # get api client for the given service name
    service = services.os_api.service(service_name)
    # filter the relevant params for the api client
    elektron_params = request.query_parameters

    # call the openstack api endpoint with given path, params and headers
    # for http methods POST, PUT, PATCH we have to consider the body parameter
    elektron_response = if ["post","put","patch"].include?(method)
      body = JSON.parse(request.body.read ) rescue request.body.read 
      service.public_send(method,path,elektron_params, headers: headers) do 
        body 
      end      
    else
      # GET, HEAD, DELETE case
      service.public_send(method,path, elektron_params, headers: headers)   
    end
    
    # render response as json
    elektron_response.header.each_header do |key, value|
      response.headers[key] = value if key.start_with? "x-"
    end
    render json: elektron_response.body
  end
end