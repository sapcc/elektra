import React from 'react'
import { useDispatch, useGlobalState } from '../StateProvider'
import { useEffect, useMemo } from 'react'
import { ajaxHelper } from 'ajax_helper';
import LoadbalancerItem from './LoadbalancerItem';
import ErrorPage from '../ErrorPage';
import {DefeatableLink} from 'lib/components/defeatable_link';
import { SearchField } from 'lib/components/search_field';
import { CSSTransition, TransitionGroup } from 'react-transition-group';
import { Link } from 'react-router-dom';
import useLoadbalancer from '../../../lib/hooks/useLoadbalancer'

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
    fetchLoadbalancers(state.marker)
  }, []);

  const loadNext = event => {
    if(!state.isLoading && state.hasNext) {
      fetchLoadbalancers(state.marker)
    }
  }

  const search = (term) => {
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
            <div className='toolbar'>
              { selected ?
                <Link className="back-link" to={`/loadbalancers`}>
                  <i className="fa fa-chevron-circle-left"></i>
                  Back to Load Balancers
                </Link>
                :
                loadbalancers.length > 0 &&
                  <SearchField
                    value={searchTerm}
                    onChange={(term) => search(term)}
                    placeholder='name, ID, description' text='Searches by name, ID or description in visible loadbalancers list only.'/> 
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
                          <th>Name/ID</th>
                          <th>Description</th>
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
              <div className='ajax-paginate'>
                { isLoading ?
                  <div className='main-buttons'><span className="spinner"></span> Loading...</div>
                  :
                  (hasNext &&
                    <div className='main-buttons'>
                    <button className='btn btn-primary btn-sm' onClick={loadNext}>Load Next</button>
                    </div>
                  )
                }
              </div>
            }
          </React.Fragment>
        }

      </React.Fragment>
    )
  } , [ JSON.stringify(loadbalancers), error, isLoading, searchTerm])

}
export default LoadbalancerList;
