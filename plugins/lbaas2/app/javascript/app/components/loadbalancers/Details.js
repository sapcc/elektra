import React, { useState, useEffect } from 'react';
import { useDispatch, useGlobalState } from '../StateProvider'
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import ErrorPage from '../ErrorPage';

const Details = (props) => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const fetchLoadbalancer = useLoadbalancer()
  const [error, setError] = useState(null)

  useEffect(() => {
    console.log('FETCH details')
    connect()
    return function cleanup() {
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: ""})
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: null})
    };
  }, []);

  const connect = () => {
    let loadbalancer;
    let id = props.match && props.match.params && props.match.params.id

    if (id) {
      dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: id})
      dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: id})

      loadbalancer = state.items.find(item => item.id == id)
      if (loadbalancer) {
        console.log("DETAILS loadbalancer found")
        dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: loadbalancer})
      } else {
        console.log("DETAILS fetch loadbalancer")
        fetchLoadbalancer(id).then((response) => {
          dispatch({type: 'SELECT_LOADBALANCER', loadbalancer: response})
        }).catch((error) => {
          console.log("Error->", error)
          setError(error)
        })
      }
    }
  }

  return ( 
    <React.Fragment>      
      {error ?
        <ErrorPage headTitle="Load Balancers Details" error={error}/>
        :
        <React.Fragment>
          <h3>Details</h3>
          <p>Something</p>
        </React.Fragment>
      }
    </React.Fragment>
   );
}
 
export default Details;