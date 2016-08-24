module DnsService
  class Recordset < Core::ServiceLayer::Model
    TYPE_LABELS = {
      "A - Address record" => "a", 
      "AAAA - IPv6 address record" => "aaaa",
      "CNAME - Canonical name record" => "cname",
      "MX - Mail exchangerecord" => "mx",
      "PTR - Pointer record" => "ptr",
      "SPF - Sender Policy Framework" => "spf",
      "SRV - Service locator" => "srv",
      "SSHFP - SSH Public Key Fingerprint" => "sshfp",
      "TXT - Text record" => "txt"
    }
      
    CONTENT_LABELS = { 
      a: {label: "IPv4 Address", type: 'string'}, 
      aaaa: {label: "IPv6 Address", type: 'string'}, 
      cname: {label: "Canonical Name", type: 'string'}, 
      mx: {label: "Mail Server", type: 'string'}, 
      ptr: {label: "PTR Domain Name", type: 'string'}, 
      spf: {label: "Text", type: 'text'}, 
      srv: {label: "Value", type: 'string'}, 
      sshfp: {label: "SSH Public Key", type: 'text'}, 
      txt: {label: "Text", type: 'text'}
    }
    
    validates :type, presence: {message: 'Please select a type'}
    validates :name, presence: {message: 'Please provide a name'}
    validates :records, presence: {message: 'Please provide a content'}
    
    def attributes_for_create
      {
        "type"        => (read("type").upcase rescue nil),
        "name"        => "#{read('name')}.#{read('zone_name')}",
        "records"     => (read("records").is_a?(Array) ? read("records") : [read("records")]),
        "ttl"         => (read("ttl") ? read("ttl").to_i : nil),
        "description" => read("description"),
        "zone_id"     => read("zone_id"),
      }.delete_if { |k, v| v.blank? }
    end
    
    def attributes_for_update
      {
        "type"        => (read("type").upcase rescue nil),
        "name"        => read('name'),
        "records"     => (read("records").is_a?(Array) ? read("records") : [read("records")]),
        "ttl"         => (read("ttl") ? read("ttl").to_i : nil),
        "description" => read("description"),
        "zone_id"     => read("zone_id"),
      }.delete_if { |k, v| v.blank? }
    end
  end
end