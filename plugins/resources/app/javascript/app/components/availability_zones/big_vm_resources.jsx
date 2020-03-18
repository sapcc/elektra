import ResourceName from "../resource_name";
import ResourceBar from "../resource_bar";

const AvailableBigVmResources = ({ bigVmResources }) => {
  const availabilityZones = Object.keys(bigVmResources).sort();
  const hv_sizes = {};
  Object.keys(bigVmResources).map(az =>
    Object.keys(bigVmResources[az]).map(
      memory_size => (hv_sizes[memory_size] = bigVmResources[az][memory_size] )
    )
  );
  const azColumnWidth = Math.floor(10 / availabilityZones.length);

  // there is only one HV per az and memory size
  function get_available_capacity(capacity) {
    if (capacity) {
      return 1;
    } else {
      return 0;
    }
  }

  if (Object.keys(availabilityZones).length > 0) {
    return (
      <React.Fragment>
        <h3>Available BigVM Resources</h3>
        <div className="row">
          <div className="col-md-2"> </div>
          {availabilityZones.map(az => (
            <div key={az} className={`col-md-${azColumnWidth}`}>
              <h4>{az}</h4>
            </div>
          ))}
        </div>

        {Object.keys(hv_sizes)
          .sort()
          .map(memory_size => (
            <div key={memory_size} className="row">
              <ResourceName
                name={memory_size + "TiB Hypervisor"}
                flavorData={{ primary: ["Available BigVMs",hv_sizes[memory_size]] , secondary: true}}
              />
              {availabilityZones.map(az => (
                <div
                  key={az + "-" + memory_size}
                  className={`col-md-${azColumnWidth}`}
                >
                  <ResourceBar
                    capacity={get_available_capacity(memory_size)}
                    fill={0}
                    labelOverride={"Available"}
                    showsCapacity={true}
                  />
                </div>
              ))}
            </div>
          ))}
      </React.Fragment>
    );
  } else {
    return <React.Fragment></React.Fragment>;
  }
};

export default AvailableBigVmResources;
