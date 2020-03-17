import React, { useState, useEffect } from 'react';
import { useDispatch, useGlobalState } from '../StateProvider'
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import ErrorPage from '../ErrorPage';
import { Redirect } from 'react-router-dom'
import ListenerList from '../listeners/ListenerList'
import PoolList from '../pools/PoolList'

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
    let id = props.match && props.match.params && props.match.params.id
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
        return <h3>Details for {loadbalancer.name} <small>({loadbalancer.id})</small></h3>
      } else {
        return <h3>Details for {loadbalancer.id}</h3>
      }
    }
  }

  let loadbalancer = state.items.find(item => item.id == loadbalancerId) 
  return ( 
    <React.Fragment>      
      {error ?
        <ErrorPage headTitle="Load Balancers Details" error={error}/>
        :
        <React.Fragment>
          { !loadbalancer && !loading && selected &&
            <Redirect to="/loadbalancers"/>
          }
          {/* title */}
          {headerTitle(loading, loadbalancer)}
          
          {/* listeners */}
          <ListenerList/>

          {/* pools */}
          <PoolList />

        </React.Fragment>
      }
    </React.Fragment>
   );
}
 
export default Details;