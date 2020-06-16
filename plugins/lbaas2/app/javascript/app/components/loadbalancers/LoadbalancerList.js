import React, { useState } from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect, useMemo } from 'react'
import LoadbalancerItem from './LoadbalancerItem';
import ErrorPage from '../ErrorPage';
import {DefeatableLink} from 'lib/components/defeatable_link';
import { SearchField } from 'lib/components/search_field';
import { CSSTransition, TransitionGroup } from 'react-transition-group';
import { Link } from 'react-router-dom';
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'
import { Tooltip, OverlayTrigger, ToggleButton, ToggleButtonGroup, ButtonToolbar } from 'react-bootstrap';
import Pagination from '../shared/Pagination'

const TableFadeTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={200} unmountOnExit classNames="css-transition-fade">
  {children}
</CSSTransition>);


const LoadbalancerList = (props) => {
  const dispatch = useDispatch()
  const state = useGlobalState().loadbalancers
  const {fetchLoadbalancers} = useLoadbalancer()


  useEffect(() => {
    console.log('FETCH initial loadbalancers')
    fetchLoadbalancers({marker: state.marker})
  }, []);

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchLoadbalancers({marker: state.marker})
    }
  }

  const handlePaginateClick = (e,page) => {
    e.preventDefault()
    if (page === "all") {
      fetchLoadbalancers({limit: 9999});
    } else {
      fetchLoadbalancers({marker: state.marker});
    }
  };

  const search = (term) => {
    if(hasNext && !isLoading) {
      fetchLoadbalancers({limit: 9999});
    }
    dispatch({type: 'SET_LOADBALANCER_SEARCH_TERM', searchTerm: term})
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
  const loadbalancers =  filterItems(searchTerm, items)
  return useMemo(() => {
    console.log("RENDER loadbalancer list")
    return (
      <React.Fragment>
        {error ?
          <ErrorPage headTitle="Load Balancers" error={error}/>
          :
          <React.Fragment>
            <div className='toolbar searchToolbar'>
              { selected ?
                <Link className="back-link" to={`/loadbalancers`}>
                  <i className="fa fa-chevron-circle-left"></i>
                  Back to Load Balancers
                </Link>
                :
                <React.Fragment>
                  <SearchField
                    value={searchTerm}
                    onChange={(term) => search(term)}
                    placeholder='name, ID or description' text='Searches by name, ID or description in visible loadbalancers list only.'/> 
                </React.Fragment> 
              }
              <div className="main-buttons">
                {!selected &&
                  <DefeatableLink
                    disabled={isLoading}
                    to='/loadbalancers/new'
                    className='btn btn-primary'>
                    New Load Balancer
                  </DefeatableLink> 
                }
              </div>
            </div>
            
            <TransitionGroup>
              <TableFadeTransition key={loadbalancers.length}>
                <table className={selected ? "table loadbalancers" : "table table-hover loadbalancers"}>
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
                          <th>State</th>
                          <th>Prov. Status</th>
                          <th>Tags</th>
                          <th className="snug-nowrap">Subnet/IP Address</th>
                          <th>#Listeners</th>
                          <th>#Pools</th>
                          <th className='snug'></th>
                      </tr>
                  </thead>
                  <tbody>
                    {loadbalancers && loadbalancers.length>0 ?
                      loadbalancers.map( (loadbalancer, index) =>
                        <LoadbalancerItem 
                          loadbalancer={loadbalancer}
                          disabled={selected ? true : false}
                          key={index}
                          searchTerm={searchTerm}
                        />
                      )
                      :
                      <tr>
                        <td colSpan="8">
                          { isLoading ? <span className='spinner'/> : 'No loadbalancers found.' }
                        </td>
                      </tr>  
                    }
                  </tbody>
                </table>
                
              </TableFadeTransition>
            </TransitionGroup>
            

            {loadbalancers.length > 0 && !selected &&
              <Pagination isLoading={isLoading} items={state.items} hasNext={hasNext} handleClick={handlePaginateClick}/>
            }

          </React.Fragment>
        }

      </React.Fragment>
    )
  } , [ JSON.stringify(loadbalancers), error, selected, isLoading, searchTerm, hasNext])

}
export default LoadbalancerList;
