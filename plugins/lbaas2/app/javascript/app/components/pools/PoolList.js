import React from 'react';
import usePool from '../../../lib/hooks/usePool'
import { useEffect } from 'react'
import {DefeatableLink} from 'lib/components/defeatable_link';
import PoolItem from './PoolItem'
import queryString from 'query-string'
import { Link } from 'react-router-dom';
import HelpPopover from '../shared/HelpPopover'
import useCommons from '../../../lib/hooks/useCommons'
import { useGlobalState } from '../StateProvider'

const PoolList = ({props, loadbalancerID}) => {
  const {persistPools, setSearchTerm, setSelected, reset} = usePool()
  const {searchParamsToString} = useCommons()
  const state = useGlobalState().pools

  useEffect(() => {  
    persistPools(loadbalancerID, null).then((data) => {
      selectPool(data)
    }).catch( error => {
      // TODO
    })
  }, [loadbalancerID]);

  const selectPool = (data) => {
    const values = queryString.parse(props.location.search)
    const id = values.pool
    if (id) {
      // check if id belows to the lb object
      const index = data.pools.findIndex((item) => item.id==id);
      if (index>=0) {
        // pool was selected
        setSelected(id)
        // filter the pool list to show just the one item
        setSearchTerm(id)
      }
    }
  }

  const onSelectPool = (poolID) => {
    const id = poolID || ""
    const pathname = props.location.pathname; 
    const searchParams = new URLSearchParams(props.location.search); 
    searchParams.set("pool", id);
    props.history.push({
      pathname: pathname,
      search: searchParams.toString()
    })
    // pool was selected
    setSelected(poolID)
    // filter the pool list to show just the one item
    setSearchTerm(poolID)
  }

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool()
  }

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchPools(loadbalancerID, state.marker)
    }
  }

  const error = state.error
  const hasNext = state.hasNext
  const items = state.items
  const selected = state.selected
  const searchTerm = state.searchTerm

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

  const pools = filterItems(searchTerm, items)
  const isLoading = state.isLoading

  console.log("RENDER pool list")
  return ( 
    <div className="details-section">
      <div className="display-flex">
        <h4>Pools</h4>
        <HelpPopover text="Object representing the grouping of members to which the listener forwards client requests. Note that a pool is associated with only one listener, but a listener might refer to several pools (and switch between them using layer 7 policies)." />
      </div>
      
      {error ?
        <ErrorPage headTitle="Load Balancers Pools" error={error}/>
        :
        <React.Fragment>

          <div className='toolbar'>
            { selected &&
              <Link className="back-link" to="#" onClick={restoreUrl}>
                <i className="fa fa-chevron-circle-left"></i>
                Back to Pools
              </Link>
            }

            <div className="main-buttons">
              {!selected &&
                <DefeatableLink
                  disabled={isLoading}
                  to={`/loadbalancers/${loadbalancerID}/pools/new?${searchParamsToString(props)}`}
                  className='btn btn-primary'>
                  New Pool
                </DefeatableLink>
              }
            </div>
          </div>
          
          <table className={selected ? "table table-section pools" : "table table-hover pools"}>
            <thead>
                <tr>
                    <th>Name/ID</th>
                    <th>Description</th>
                    <th>State</th>
                    <th>Prov. Status</th>
                    <th>Tags</th>
                    <th>Protocol</th>
                    <th>Algorithm</th>
                    <th>#Members</th>
                    <th className='snug'></th>
                </tr>
            </thead>
            <tbody>
              {pools && pools.length>0 ?
                pools.map( (pool, index) =>
                  <PoolItem 
                  pool={pool} 
                  searchTerm={searchTerm} 
                  key={index} 
                  onSelectPool={onSelectPool}
                  disabled={selected ? true : false}
                  />
                )
                :
                <tr>
                  <td colSpan="9">
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