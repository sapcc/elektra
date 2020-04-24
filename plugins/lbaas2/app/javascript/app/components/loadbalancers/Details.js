import React, { useState, useEffect, useMemo } from 'react';
import { useDispatch, useGlobalState } from '../StateProvider'
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import ErrorPage from '../ErrorPage';
import ListenerList from '../listeners/ListenerList'
import PoolList from '../pools/PoolList'
import L7PolicyList from '../l7policies/L7PolicyList'
import L7ERuleList from '../l7Rules/L7RuleList'
import MemberList from '../members/MemberList'

const Details = (props) => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const selected = state.selected
  const {fetchLoadbalancer} = useLoadbalancer()

  const [error, setError] = useState(null)
  const [loadbalancerId, setLoadbalancerId] = useState(null)
  const [loading, setLoading] = useState(false)
  
  useEffect(() => {
    console.log('FETCH details')
    connect()
    return function cleanup() {
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: ""})
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: null})
    };
  }, []);

   const connect = () => {
    let id = props.match && props.match.params && props.match.params.loadbalancerID
    setLoadbalancerId(id)

    if (id) {
      // filter the loadbalancer list to show just the one item
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: id})
      // set to selected to disable elementes on the loadbalancer list
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: id})

      const loadbalancer = state.items.find(item => item.id == id)
      if (loadbalancer) {
        dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: loadbalancer})
      } else {
        setLoading(true)
        fetchLoadbalancer(id).then((response) => {
          dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: response})
          setLoading(false)
        }).catch((error) => {          
          setError(error)
          setLoading(false)
        })
      }
    }
  }

  const headerTitle = (loading, lb) => {
    if (loading) {
      return <h3>Details for <small><span className='spinner'/></small></h3>
    } 
    if (loadbalancer) {
      if (loadbalancer.name) {
        return <h3>Details for <b>{loadbalancer.name}</b> <small>({loadbalancer.id})</small></h3>
      } else {
        return <h3>Details for {loadbalancer.id}</h3>
      }
    }
  }

  let loadbalancer = state.items.find(item => item.id == loadbalancerId) 

  return useMemo(() => {
    console.log("RENDER Details list")
    return ( 
      <React.Fragment>      
        {error ?
          <ErrorPage headTitle="Load Balancers Details" error={error}/>
          :
          <React.Fragment>
  
            {headerTitle(loading, loadbalancer)}
            
            {loadbalancer &&        
              <React.Fragment>
  
                <ListenerList props={props} loadbalancerID={loadbalancer.id}/>
  
                <div className="multiple-subtable">
                  <L7PolicyList props={props} loadbalancerID={loadbalancer.id} /> 
                  <L7ERuleList props={props} loadbalancerID={loadbalancer.id}/>
                </div>
  
                <PoolList props={props} loadbalancerID={loadbalancer.id}/>
                <MemberList props={props}/>
                
              </React.Fragment>
            }
  
          </React.Fragment>
        }
      </React.Fragment>
     );
  },[error, loading, loadbalancer, props])

}
 
export default Details;