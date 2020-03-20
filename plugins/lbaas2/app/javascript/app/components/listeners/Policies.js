import React, { useState } from 'react';
import {DefeatableLink} from 'lib/components/defeatable_link';

const Policies = () => {
  const [isLoading, setIsLoading] = useState(false)
  const [selected, setSelected] = useState(null)

  return ( 
    <div className="highlight">
      <h5>L7 Policies</h5>
      <p>ollection of L7 rules that get logically ANDed together as well as a routing policy for any given HTTP or terminated HTTPS client requests which match said rules. An L7 Policy is associated with exactly one HTTP or terminated HTTPS listener.</p>

      <div className='toolbar'>
        <div className="main-buttons">
          <DefeatableLink
            disabled={selected || isLoading}
            to='/policies/new'
            className='btn btn-primary'>
            New
          </DefeatableLink>
        </div>
      </div>  

      <table className="table table-hover policies">
        <thead>
            <tr>
                <th>Name/ID</th>
                <th>Description</th>
                <th>State</th>
                <th>Prov. Status</th>
                <th>Position</th>
                <th>Action</th>
                <th>Redirect To</th>
                <th>#Rules</th>
                <th className='snug'></th>
            </tr>
        </thead>
        <tbody>
          <tr>
            <td colSpan="8">
              { isLoading ? <span className='spinner'/> : 'No L7 policies found.' }
            </td>
          </tr>  
        </tbody>
      </table>
    </div>    
   );
}
 
export default Policies;