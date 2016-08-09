class IndexNodesServiceParamError < StandardError
  attr_accessor :type, :operation
  def initialize(_type, _operation)
    @type, @operation = _type, _operation
    super("#{_operation}")
  end
end

class IndexNodesService

  attr_reader :automation_service, :compute_service

  def initialize(_automation_service, _compute_service)
    if _automation_service.blank?
      raise IndexNodesServiceParamError.new('automation_service', 'Automation service parameter empty.')
    end
    if _compute_service.blank?
      raise IndexNodesServiceParamError.new('compute_service', 'Compute service parameter empty.')
    end
    @automation_service = _automation_service
    @compute_service = _compute_service
  end

  def list_nodes_with_jobs(page, per_page)
    # convert array of compute instances to hash with addresses
    compute_instances = Hash[@compute_service.servers.collect { |item| [item.id, item.addresses] } ]
    # get nodes from arc
    nodes = @automation_service.nodes("", ['online', 'platform', 'platform_version', 'hostname', 'os', 'ipaddress'], page, per_page)
    # init variables
    jobs = {}
    addresses = {}

    nodes[:elements].each do |a|
      unless compute_instances[a.id].blank?
        addresses[a.id.to_sym] = compute_instances[a.id]
      end
      jobs[a.id.to_sym] = @automation_service.jobs(a.id, 1, 5)
    end
    nodes[:addresses] = addresses
    nodes[:jobs] = jobs
    nodes
  end

end