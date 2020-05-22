import React from 'react';
import { Table } from 'react-bootstrap'
import NewMemberListItem from './NewMemberListItem'

const NewMemberList = ({members, onRemoveMember, results}) => {

  console.log("RENDER NewMemberList")
  return ( 
    <Table className="table new_members" responsive>
      <thead>
          <tr>
              <th>#</th>
              <th>Name</th>
              <th><abbr title="required">*</abbr>Address</th>
              <th><abbr title="required">*</abbr>Protocol Port</th>
              <th style={{width:"10%"}}>Weight</th>
              <th style={{width:"20%"}}>Tags</th>
              <th></th>
          </tr>
      </thead>
      <tbody>
        {members && members.length>0 ?
          members.map( (member, index) =>
            <NewMemberListItem member={member} key={member.id} index={index} onRemoveMember={onRemoveMember} results={results[member.id]}/>
          )
        :
          <tr>
            <td colSpan="5">
              No Members added.
            </td>
          </tr>
        }
      </tbody>
    </Table>
   );
}
 
export default NewMemberList;