class InstallNodeError < StandardError
  attr_accessor :options
  def initialize(_message, _options = {})
    @options = _options
    super(_message.to_s)
  end
end
class InstallNodeParamError < InstallNodeError
end
class InstallNodeInstanceOSNotFound < InstallNodeError
end
class InstallNodeNoInstructionsFound < InstallNodeError
end

class InstallNodeService
  def process_request(
    instance_id,
    instance_type,
    instance_os,
    compute_service,
    automation_service
  )
    # check instance id
    if instance_id.blank?
      raise InstallNodeParamError.new(
              "Instance ID empty",
              { type: "instance_id" },
            )
    end

    # check just in case of compute instance
    if instance_type == "compute"
      return(
        process_request_compute(
          instance_id,
          instance_os,
          compute_service,
          automation_service,
        )
      )
    else
      return(
        process_request_external(instance_id, instance_os, automation_service)
      )
    end
  end

  private

  def process_request_compute(
    instance_id,
    instance_os,
    compute_service,
    automation_service
  )
    messages = []

    # get the compute instance
    instance = compute_service.find_server(instance_id)

    # check if we got an instance
    if instance.nil?
      raise InstallNodeParamError.new(
              "Compute instance with ID #{instance_id} not found",
              { type: "instance_id", messages: messages },
            )
    end

    # check if node already exists
    node_found = node_exists?(instance_id, automation_service)
    if node_found == true
      messages << {
        key: "warning",
        message:
          "Node already exists on instance #{instance.name} (#{instance.image_object.name})",
      }
    end

    # if instance_os is not given then we check the metadata or we ask for
    if instance_os.blank?
      # check image metadata
      if instance.image_object.nil? || instance.image_object.metadata.nil? ||
           instance.image_object.metadata["os_family"].blank? ||
           (
             instance.image_object.metadata["os_family"] !=
               ::Automation::Node::OsTypes::WINDOWS &&
               instance.image_object.metadata["os_family"] !=
                 ::Automation::Node::OsTypes::LINUX
           )
        raise InstallNodeInstanceOSNotFound.new(
                "Instance OS empty or not known",
                { instance: instance, messages: messages },
              )
      else
        instance_os = instance.image_object.metadata["os_family"]
      end
    end

    # get the registration url and log info
    script =
      begin
        automation_service.node_install_script(
          instance_id,
          { "headers" => { "Accept" => accept_header(instance_os) } },
        )
      rescue StandardError
        # Rails.logger.error "Automation-plugin: show_instructions: process_request_compute: #{exception.message}"
        raise InstallNodeError.new(
                "Internal Server Error. Something went wrong while processing your request. Please try again later.",
                { instance: instance, messages: messages },
              )
      end

    {
      log_info: create_login_info(instance),
      instance: instance,
      script: script,
      messages: messages,
    }
  end

  def process_request_external(instance_id, instance_os, automation_service)
    messages = []

    # check if node already exists
    node_found = node_exists?(instance_id, automation_service)
    if node_found == true
      messages << {
        key: "warning",
        message: "Node already exists with id #{instance_id}",
      }
    end

    # check os
    if instance_os.blank?
      raise InstallNodeInstanceOSNotFound.new("Instance OS empty or not known")
    end

    # get the registration url and log info
    script =
      begin
        automation_service.node_install_script(
          instance_id,
          { "headers" => { "Accept" => accept_header(instance_os) } },
        )
      rescue => exception
        # Rails.logger.error "Automation-plugin: show_instructions: process_request_external: #{exception.message}"
        raise InstallNodeError.new(
                "Internal Server Error. Something went wrong while processing your request. Please try again later.",
              )
      end

    { script: script, messages: messages }
  end

  def accept_header(instance_os)
    if instance_os == ::Automation::Node::OsTypes::WINDOWS
      return "text/x-powershellscript"
    else
      return "text/x-shellscript"
    end
  end

  def create_login_info(instance)
    ip =
      (
        if instance.addresses.values.blank?
          ""
        else
          instance.addresses.values.first.find { |i| i["addr"] }["addr"]
        end
      )
    dns_name =
      (
        if !instance.metadata.blank? && !instance.metadata.dns_name.blank?
          instance.metadata.dns_name
        else
          ""
        end
      )
    result = ""
    result << ip if !ip.blank?
    result << " / #{dns_name}" if !dns_name.blank?
    result
  end

  def node_exists?(instance_id, automation_service)
    begin
      automation_service.node(CGI.escape(instance_id))
    rescue ArcClient::ApiError => exception
      if exception.code == 404
        return false
      else
        return true
      end
    end
  end
end
