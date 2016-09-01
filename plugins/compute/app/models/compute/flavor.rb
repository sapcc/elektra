module Compute
  class Flavor < Core::ServiceLayer::Model
    def to_s
      "#{self.name}, #{self.vcpus} VCPUs, #{self.disk}GB Disk, #{self.ram}MB Ram" 
    end
  end
end