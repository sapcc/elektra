class OsApiController < ::AjaxController
  def token
    render json: current_user.context
  end
  def auth_token
    render plain: current_user.token
  end

  # Example how to use in browser
  # fetch("os-api/SERVICE_NAME/SERVICE_PATH?headers=HEADERS_AS_JSON")

  # This method implements a reverse proxy to openstack API
  def reverse_proxy
    # get http method from request
    method = request.method.downcase
    # get path undecoded from request or from params (decoded)
    path = request.path.split("os-api")[1] || params[:path]
    # remove leading slash
    path = path.gsub(/^\//, "")
    
    # get path from request
    #path = params[:path]
    # we remove the first part of path. It is the openstack service name
    service_path = path.split("/", 2)
    service_name = service_path[0]
    # the rest is the current path
    path = service_path[1] || ""

    headers = {}
    request.headers.each do |name, value|
      if name.start_with?("HTTP_OS_API")
        headers[name.gsub("HTTP_OS_API_", "").gsub("_", "-")] = value
      end
    end
    # rename content type to fit elektron's key :(
    if headers["CONTENT-TYPE"]
      headers["Content-Type"] = headers["CONTENT-TYPE"]
      headers.delete("CONTENT-TYPE")
    end

    # byebug

    # get api client for the given service name
    service = services.os_api.service(service_name)
    # filter the relevant params for the api client
    elektron_params = request.query_parameters

    # call the openstack api endpoint with given path, params and headers
    # for http methods POST, PUT, PATCH we have to consider the body parameter
    elektron_response =
      if %w[post put patch].include?(method)
        body = request.body.read
        service.public_send(method, path, elektron_params, headers: headers) do
          body
        end
        # GET, HEAD, DELETE case
      else
        service.public_send(method, path, elektron_params, headers: headers)
      end

    # render response as json
    elektron_response.header.each_header do |key, value|
      new_key = key.start_with?("x-") ? key : "x-#{key}"
      response.set_header(new_key, value)
    end

    if params[:inline]
      # # headers["Content-Disposition"] = "inline"
      # # headers["Content-Type"] = elektron_response.header["Content-Type"]
      # # headers["Content-Transfer-Encoding"]="binary"
      # # headers["Content-Length"]= elektron_response.header["Content-Length"]
      # # byebug
      # # if elektron_response.body.is_a?(Hash)
      # #   return render plain: elektron_response.body.to_json
      # # end
      # # render plain: elektron_response.body.to_s
      # elektron_response.header.each_header do |key, value|
      #   headers[key] = value
      # end
      # send_data elektron_response.body, disposition: "inline"
      # #render plain: elektron_response.body
      if elektron_response.header["Content-Type"].include?("application/json")
        render plain: elektron_response.body.to_json
      elsif elektron_response.header["Content-Type"].include?("application/octet-stream") ||
        elektron_response.header["Content-Type"].include?("application/pdf") || 
        elektron_response.header["Content-Type"].start_with?("audio") || 
        elektron_response.header["Content-Type"].start_with?("image")  
        send_data elektron_response.body, disposition: "inline", type: elektron_response.header["Content-Type"]
      elsif elektron_response.header["Content-Type"].start_with?("video") 
        send_data elektron_response.body, disposition: "inline", type: elektron_response.header["Content-Type"]
      else
        render plain: elektron_response.body 
      end
    else
      render json: elektron_response.body, status: elektron_response.header.code
    end
  rescue => e
    # pp "......................................ERROR"
    # pp e
    # byebug
    render json: { error: e.response.body || e.message }, status: e.code
  end
end
