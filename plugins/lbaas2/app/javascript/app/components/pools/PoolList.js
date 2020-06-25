import { useEffect, useMemo } from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import usePool from '../../../lib/hooks/usePool'
import {DefeatableLink} from 'lib/components/defeatable_link';
import PoolItem from './PoolItem'
import queryString from 'query-string'
import { Link } from 'react-router-dom';
import HelpPopover from '../shared/HelpPopover'
import useCommons from '../../../lib/hooks/useCommons'
import { Tooltip, OverlayTrigger } from 'react-bootstrap';
import { addError } from 'lib/flashes';
import Pagination from '../shared/Pagination'
import { SearchField } from 'lib/components/search_field';
import { policy } from "policy";
import { scope } from "ajax_helper";
import SmartLink from "../shared/SmartLink"

const PoolList = ({props, loadbalancerID}) => {
  const dispatch = useDispatch()
  const {persistPools, setSearchTerm, setSelected, onSelectPool} = usePool()
  const {searchParamsToString} = useCommons()
  const state = useGlobalState().pools

  useEffect(() => {  
    initLoad()
  }, [loadbalancerID]);

  const initLoad = () => {
    console.log("FETCH POOLS")
    persistPools(loadbalancerID, true, null).then((data) => {
      selectPool(data)
    }).catch( error => {
      // TODO
    })
  }

  const canCreate = useMemo(
    () => 
      policy.isAllowed("lbaas2:pool_create", {
        target: { scoped_domain_name: scope.domain }
      }),
    [scope.domain]
  );

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
      } else {
        addError(<React.Fragment>Pool <b>{id}</b> not found.</React.Fragment>)
      }
    }
  }

  const handlePaginateClick = (e,page) => {
    e.preventDefault()
    if (page === "all") {
      persistPools(loadbalancerID, false, {limit: 9999})
    } else {
      persistPools(loadbalancerID, false, {marker: state.marker})
    }
  };

  const restoreUrl = (e) => {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    onSelectPool(props)
  }

  const search = (term) => {
    if(hasNext && !isLoading) {
      persistPools(loadbalancerID, false, {limit: 9999})
    }
    dispatch({type: 'SET_POOLS_SEARCH_TERM', searchTerm: term})
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
      `${i.id} ${i.name} ${i.description} ${i.protocol}`.search(regex) >= 0
    )
    }
  }

  const pools = filterItems(searchTerm, items)
  const isLoading = state.isLoading

  return useMemo(() => {
    console.log("RENDER pool list")
    return ( 
      <div className="details-section">
        <div className="display-flex">
          <h4>Pools</h4>
          <HelpPopover text="Object representing the grouping of members to which the listener forwards client requests. Note that a pool is associated with only one listener, but a listener might refer to several pools (and switch between them using layer 7 policies)." />
        </div>
        
        {error ?
          <ErrorPage headTitle="Load Balancers Pools" error={error} onReload={initLoad}/>
          :
          <React.Fragment>

            <div className='toolbar'>
              { selected ?
                <Link className="back-link" to="#" onClick={restoreUrl}>
                  <i className="fa fa-chevron-circle-left"></i>
                  Back to Pools
                </Link>
                :
                <SearchField
                  value={searchTerm}
                  onChange={(term) => search(term)}
                  placeholder='name, ID, desc. or protocol' text='Searches by name, ID,description or protocol. All pools will be loaded.'/> 
              }

              <div className="main-buttons">
                {!selected &&
                  <SmartLink
                    disabled={isLoading}
                    to={`/loadbalancers/${loadbalancerID}/pools/new?${searchParamsToString(props)}`}
                    className='btn btn-primary'
                    isAllowed={canCreate}
                    notAllowedText="Not allowed to create. Please check with your administrator.">
                    New Pool
                  </SmartLink>
                }
              </div>
            </div>
            
            <table className={selected ? "table table-section pools" : "table table-hover pools"}>
              <thead>
                  <tr>
                    <th>
                      <div className="display-flex">
                        Name
                        <div className="margin-left">
                        <OverlayTrigger placement="top" overlay={<Tooltip id="defalult-pool-tooltip">Sorted by Name ASC</Tooltip>}>
                          <i className="fa fa-sort-asc" />
                        </OverlayTrigger>  
                        </div>
                        /ID/Description
                      </div>
                    </th>
                    <th>State/Prov. Status</th>
                    <th>Tags</th>
                    <th>Algorithm</th>
                    <th>Protocol</th>
                    <th>Session Persistence</th>
                    <th>Assigned to</th>
                    <th>TLS enabled/Secrets</th>
                    <th>#Members</th>
                    <th className='snug'></th>
                  </tr>
              </thead>
              <tbody>
                {pools && pools.length>0 ?
                  pools.map( (pool, index) =>
                    <PoolItem
                    props={props} 
                    pool={pool} 
                    searchTerm={searchTerm} 
                    key={index} 
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

            {pools.length > 0 && !selected &&
              <Pagination isLoading={isLoading} items={state.items} hasNext={hasNext} handleClick={handlePaginateClick}/>
            }

          </React.Fragment>
        }
      </div>
    );
  } , [ JSON.stringify(pools), error, isLoading, searchTerm, selected, props, hasNext])
}
 
export default PoolList
;