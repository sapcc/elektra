import React from 'react';
import { useMemo } from 'react'
import { useGlobalState } from './StateProvider'
import { Label, Tooltip, OverlayTrigger } from 'react-bootstrap';

const StateLabel = ({lbId, placeholder, path}) => {
  const trees = useGlobalState().statusTrees.trees
  const tree = trees.find(tree => tree.id === lbId)
  
  const treeState = (pathParts, structure) => {
    const part = pathParts[0]
    // console.log("pathParts-->", pathParts)
    // console.log("part-->", part)
    // console.log("structure", structure)
    if (part) {
      if (Array.isArray(structure)) {
        // console.log("is an array")
        const index = structure.findIndex((item) => {
          // console.log("item.id-->", item.id)
          return item.id==part
        });
        // console.log("index-->", index)
        if (index >= 0) {
          return treeState(pathParts.slice(1), structure[index])
        }
        return null
      }
      if (typeof structure == "object") {
        // console.log("is an object: pathParts:", pathParts," part:", part, " structure: ", structure)
        if (pathParts.length > 1) {
          return treeState(pathParts.slice(1), structure[part])
        } 
        // console.log("returning end-->", structure[part])
        return structure[part]
      }
    } 
    return null
  }

  const labelAttributes = (status) => {
    switch (status) {
      case 'ONLINE':
        return {className: "label-success", title: "Entity is operating normally"}
      case 'ACTIVE':
        return {className: "label-success", title: "The entity was provisioned successfully"}
      case 'DELETED':
        return {className: "label-success", title: "The entity has been successfully deleted"}
        
      case 'DRAINING':
        return {className: "label-warning-greyscale", title: "The member is not accepting new connections"}
      case 'DEGRADED':      
        return {className: "label-warning-greyscale", title: "One or more of the entity’s components are in ERROR"}
      case 'OFFLINE':
        return {className: "label-warning-greyscale", title: "Entity is administratively disabled"}
      case 'NO_MONITOR':
        return {className: "label-warning-greyscale", title: "No health monitor is configured for this entity and it’s status is unknown"}
  
      case 'ERROR':
        return {className: "label-danger", title: "Entity is not working/deployed properly"}
  
      case "PENDING_CREATE":
        return {className: 'label-warning', title: "The entity is being created"}
      case "PENDING_UPDATE":
        return {className: 'label-warning', title: "TThe entity is being updated"}
      case "PENDING_DELETE":
        return {className: 'label-warning', title: "The entity is being deleted"}
      default:
        return {className: 'label-info', title: "Unknown state"}
    }
  }

  let params = labelAttributes(placeholder)
  let label = placeholder
  if (tree) {
    // const test = 'listeners/57c982fd-a43a-4caa-ac2e-6277f92f3402/pools/caaa477b-bc0e-4705-94e6-c51911956d2a/operating_status'
    label = treeState(path.split("/"), tree)
    params = labelAttributes(label)
  }

  return useMemo(() => {
    console.log("RENDER state label result-->",label)
    return ( 
      <React.Fragment>
        <OverlayTrigger placement="top" overlay={<Tooltip id="static-label-tooltip">{params.title}</Tooltip>}>
          <Label className={params.className}>{label}</Label>
        </OverlayTrigger>      
      </React.Fragment>
    );
  }, [tree, placeholder])
}
 
export default StateLabel;