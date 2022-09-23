class OsApiController < ::AjaxController

  def auth_token
    render plain: current_user.token
  end
  
  # Example how to use in browser
  # fetch("os-api/SERVICE_NAME/SERVICE_PATH?headers=HEADERS_AS_JSON")

  # This method implements a reverse proxy to openstack API
  def reverse_proxy 
    # get http method from request
    method = request.method.downcase
    # get path from request
    path = params[:path]
    # we remove the first part of path. It is the openstack service name
    service_path = path.split("/",2)
    service_name = service_path[0]
    # the rest is the current path
    path = service_path[1] || ""
    path += ".#{params[:format]}" if params[:format]

    headers = {}
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
      body = request.body.read 
      body = JSON.parse(body ) rescue body 
      service.public_send(method,path,elektron_params, headers: headers) do 
        body 
      end      
    else
      # GET, HEAD, DELETE case
      service.public_send(method,path, elektron_params, headers: headers)   
    end
    
    # render response as json
    elektron_response.header.each_header do |key, value|
      new_key = key.start_with?("x-") ? key : "x-#{key}"
      response.set_header(new_key,value)#if key.start_with? "x-"
    end

    render json: elektron_response.body
  end
end