import ResourceName from '../resource_name'
import ResourceBar from '../resource_bar';

const AvailableBigVmResources = ({ data }) => {

  const availabilityZones = Object.keys(data).sort()
  const hv_sizes = {}
  Object.keys(data).map(az => ( Object.keys(data[az]).map( memory_size => ( hv_sizes[memory_size] = "#" ))))
  const azColumnWidth = Math.floor(10 / availabilityZones.length);

  // We count big VMs per hypervisor, that means
  // 2TB HV can fit one 2TB bigVM
  // 3TB HV can fit one 3TB bigVM
  // so if we have 3 HVs that can fit 2TB VMs we can install three 2TB BigVMs in the related availability zone
  function get_available_hvs_count(hypervisors) {
    if (hypervisors) {
      return hypervisors.length
    }
    else {
      return 0
    }
  }

  if (Object.keys(availabilityZones).length > 0) {
    return (
      <React.Fragment>
        <h3>Available BigVM Resources</h3>
        <div className='row'>
          <div className='col-md-2'>{' '}</div>
          { availabilityZones.map(az => (
            <div key={az} className={`col-md-${azColumnWidth}`}><h4>{az}</h4></div>
          ))}
        </div>
        
        { Object.keys(hv_sizes).sort().map(memory_size => ( 
          <div key={memory_size} className='row'> 
            <ResourceName name={memory_size+"TB Hypervisor"} flavorData={{primary:true}} />
            { availabilityZones.map(az => (
            <div key={az+"-"+memory_size} className={`col-md-${azColumnWidth}`}>
              <ResourceBar capacity={get_available_hvs_count(data[az][memory_size])} fill={0} showsCapacity={true} />
            </div>
            ))}
          </div>
        ))}
      </React.Fragment>
    );
  } else {
    return (
      <React.Fragment>
        <h3>Available BigVM Resources</h3>
        <div className='bs-callout bs-callout-info bs-callout-emphasize'>
          At the moment no resources are available...
        </div>
      </React.Fragment>
    )
  }

}

export default AvailableBigVmResources;