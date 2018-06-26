import React from 'react'
import Groups from '../../components/groups'

describe('Groups component', () => {

  it('should render the groups', () => {
    const mockData = {id: "9d4cd354b558aa59a842bc2e74cfd18a0f0ade1ba5277bfdfcacaa50916a8072", name: "CCADMIN_CLOUD_ADMINS"}
    const wrapper = shallow(<Groups data={mockData}/>);
  })

})
