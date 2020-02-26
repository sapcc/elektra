import ResourceName from '../resource_name'
import ResourceBar from '../resource_bar';

const AvailableBigVmResources = ({ data }) => {

  const availabilityZones = Object.keys(data).sort()
  const vm_sizes = {}
  Object.keys(data).map(az => ( Object.keys(data[az]).map( memory_size => ( vm_sizes[memory_size] = "###" ))))
  const azColumnWidth = Math.floor(10 / availabilityZones.length);

  function get_possible_big_vms_count(hypervisors) {
    if (hypervisors) {
      return hypervisors.length
    }
    else {
      return 0
    }
  }

  return (
    <React.Fragment>
      <h3>Available BigVM Resources</h3>
      <div className='row'>
        <div className='col-md-2'>{' '}</div>
        {availabilityZones.map(az => (
          <div key={az} className={`col-md-${azColumnWidth}`}><h4>{az}</h4></div>
        ))}
      </div>
      
      { Object.keys(vm_sizes).sort().map(memory_size => ( 
        <div className='row'> 
          <ResourceName name={"Big VM with "+memory_size+"TB"} flavorData={{primary:true}} />
          { availabilityZones.map(az => (
          <div className={`col-md-${azColumnWidth}`}>
            <ResourceBar capacity={get_possible_big_vms_count(data[az][memory_size])} fill={0} showsCapacity={true} />
          </div>
          ))}
        </div>
      ))}
    </React.Fragment>
  );
}

export default AvailableBigVmResources;