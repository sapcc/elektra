class InstallAgentError < StandardError
  attr_accessor :options
  def initialize(_message, _options={})
    @options = _options
    super(_message.to_s)
  end
end
class InstallAgentParamError < InstallAgentError; end
class InstallAgentInstanceOSNotFound < InstallAgentError; end
class InstallAgentNoInstructionsFound < InstallAgentError; end

class InstallAgentService

  def process_request(instance_id, instance_type, instance_os, compute_service, automation_service, active_project, token)
    # check instance id
    if instance_id.blank?
      raise InstallAgentParamError.new('Instance ID empty', {type: 'instance_id'})
    end

    # check just in case of compute instance
    if instance_type == 'compute'
      return process_request_compute(instance_id, instance_os, compute_service, automation_service, active_project, token)
    else
      return process_request_external(instance_id, instance_os, automation_service, active_project, token)
    end

  end

  private

  def process_request_compute(instance_id, instance_os, compute_service, automation_service, active_project, token)
    messages = []

    # get the compute instance
    instance = begin
      compute_service.find_server(instance_id)
    rescue Core::ServiceLayer::Errors::ApiError => e
      case e.type
        when 'NotFound'
          nil
        else
          raise e
      end
    end

    # check if we got an instance
    if instance.nil?
      raise InstallAgentParamError.new("Compute instance with ID #{instance_id} not found", {type: 'instance_id', messages: messages})
    end

    # check if agent already exists
    agent_found = ((automation_service.agent(instance_id) rescue ::RestClient::ResourceNotFound) == ::RestClient::ResourceNotFound) ? false : true
    if agent_found == true
      messages << {key: "warning", message: "Agent already exists on instance #{instance.name} (#{instance.image.name})"}
    end

    # if instance_os is not given then we check the metadata or we ask for
    if instance_os.blank?
      # check image metadata
      if instance.image.metadata.nil? || instance.image.metadata['os_family'].blank? || ( instance.image.metadata['os_family'] != 'windows' && instance.image.metadata['os_family'] != 'linux')
        raise InstallAgentInstanceOSNotFound.new("Instance OS empty or not known", {instance: instance, messages: messages})
      else
        instance_os = instance.image.metadata['os_family']
      end
    end

    # get the registration url and log info
    url = begin
      registration_url(instance_id, active_project, token)
    rescue
      raise InstallAgentError.new("Internal Server Error. Something went wrong while processing your request. Please try again later.", {instance: instance, messages: messages})
    end

    {log_info: create_login_info(instance), instance: instance, script: create_script(url, instance_os), messages:messages}
  end

  def process_request_external(instance_id, instance_os, automation_service, active_project, token)
    # check if agent already exists
    agent_found = ((automation_service.agent(instance_id) rescue ::RestClient::ResourceNotFound) == ::RestClient::ResourceNotFound) ? false : true
    if agent_found == true
      messages << {key: "warning", message: "Agent already exists with id #{instance_id}"}
    end

    # check os
    if instance_os.blank?
      raise InstallAgentInstanceOSNotFound.new("Instance OS empty or not known")
    end

    # get the registration url and log info
    url = begin
      registration_url(instance_id, active_project, token)
    rescue
      raise InstallAgentError.new("Internal Server Error. Something went wrong while processing your request. Please try again later.")
    end

    {script: create_script(url, instance_os)}
  end

  def registration_url(instance_id, active_project, token)
    response = RestClient::Request.new(method: :post,
                                       url: AUTOMATION_CONF['arc_pki_url'],
                                       headers: {'X-Auth-Token': token},
                                       timeout: 5,
                                       payload: {"CN": instance_id, "names": [{"OU": active_project.id, "O": active_project.domain_id}] }.to_json).execute
    response_hash = JSON.parse(response)
    response_hash.fetch('url', "")
  end

  def create_login_info(instance)
    ip = instance.addresses.values.blank? ? "" : instance.addresses.values.first.find{|i| i['addr']}['addr']
    dns_name = !instance.metadata.blank? && !instance.metadata.dns_name.blank? ? instance.metadata.dns_name : ""
    result = ""
    if !ip.blank?
      result << ip
    end
    if !dns_name.blank?
      result << " / #{dns_name}"
    end
    result
  end

  def create_script(url, instance_os)
    if instance_os == 'linux'
      return "curl --create-dirs -o /opt/arc/arc #{AUTOMATION_CONF['arc_update_site_url']}/#{instance_os}/amd64
chmod +x /opt/arc/arc
/opt/arc/arc init --endpoint #{AUTOMATION_CONF['arc_mqtt_url']} --update-uri #{AUTOMATION_CONF['arc_update_url']} --registration-url #{url}"
    elsif instance_os == 'windows'
      return "mkdir C:\\monsoon\\arc
powershell (new-object System.Net.WebClient).DownloadFile('#{AUTOMATION_CONF['arc_update_site_url']}/#{instance_os}/amd64','C:\\monsoon\\arc\\arc.exe')
C:\monsoon\\arc\\arc.exe init --endpoint #{AUTOMATION_CONF['arc_mqtt_url']} --update-uri #{AUTOMATION_CONF['arc_update_url']} --registration-url #{url}"
    else
      raise InstallAgentNoInstructionsFound.new("No instructions found for this os #{instance_os}")
    end
  end

end