import React from 'react';
import { useDispatch, useGlobalState } from '../StateProvider'
import usePool from '../../../lib/hooks/usePool'
import { useEffect } from 'react'
import {DefeatableLink} from 'lib/components/defeatable_link';
import PoolItem from './PoolItem'

const PoolList = ({loadbalancerID}) => {
  const dispatch = useDispatch()
  const state = useGlobalState().pools
  const {fetchPools} = usePool()

  useEffect(() => {
    console.log('FETCH initial pools')
    dispatch({type: 'INIT_POOLS'})
    fetchPools(loadbalancerID, state.marker)
  }, []);

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchPools(loadbalancerID, state.marker)
    }
  }

  const error = state.error
  const isLoading = state.isLoading
  const hasNext = state.hasNext
  const searchTerm = state.searchTerm
  const items = state.items
  const selected = state.selected

  const filterItems = (searchTerm, items) => {
    if(!searchTerm) return items;
    // filter items      
    if (selected) {
      return items.filter((i) =>
        i.id == searchTerm.trim()
      )
    } else {
      const regex = new RegExp(searchTerm.trim(), "i");
      return items.filter((i) =>
      `${i.id} ${i.name} ${i.description}`.search(regex) >= 0
    )
    }
  }

  const pools =  filterItems(searchTerm, items)
  return ( 
    <div className="details-section">
      <h4>Pools</h4>
      {error ?
        <ErrorPage headTitle="Load Balancers Pools" error={error}/>
        :
        <React.Fragment>
          <div className='toolbar'>
            <div className="main-buttons">
              <DefeatableLink
                disabled={selected || isLoading}
                to='/pools/new'
                className='btn btn-primary'>
                New Pool
              </DefeatableLink>
            </div>
          </div>

          <table className="table table-hover listeners">
            <thead>
                <tr>
                    <th>Name/ID</th>
                    <th>Description</th>
                    <th>Protocol</th>
                    <th>Algorithm</th>
                    <th>#Members</th>
                    <th>State</th>
                    <th>Prov. Status</th>
                    <th className='snug'></th>
                </tr>
            </thead>
            <tbody>
              {pools && pools.length>0 ?
                pools.map( (pool, index) =>
                  <PoolItem pool={pool} searchTerm={searchTerm} key={index}/>
                )
                :
                <tr>
                  <td colSpan="8">
                    { isLoading ? <span className='spinner'/> : 'No pools found.' }
                  </td>
                </tr>  
              }
            </tbody>
          </table>  

        </React.Fragment>
      }
    </div>
   );
}
 
export default PoolList
;