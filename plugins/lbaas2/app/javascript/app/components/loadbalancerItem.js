import { Highlighter } from 'react-bootstrap-typeahead'
import { Link } from 'react-router-dom';
import LbPopover from './LbPoopover';
import StaticTags from './StaticTags';
import StateLabel from './StateLabel'
import useStatusTree from '../../lib/hooks/useStatusTree'

const MyHighlighter = ({search,children}) => {
  if(!search || !children) return children
  return <Highlighter search={search}>{children+''}</Highlighter>
}

const LoadbalancerItem = React.memo(({loadbalancer, searchTerm}) => {
  console.log('render loadbalancer list item id-->', loadbalancer.id)
  
  useStatusTree({lbId: loadbalancer.id})

  const poolIds = loadbalancer.pools.map(p => p.id)
  const listenerIds = loadbalancer.listeners.map(l => l.id)
  return(
    <tr>
      <td>
        <Link to={`loadbalancers/${loadbalancer.id}/show`}>
          <MyHighlighter search={searchTerm}>{loadbalancer.name || loadbalancer.id}</MyHighlighter>
        </Link>
        {loadbalancer.name && 
            <React.Fragment>
              <br/>
              <span className="info-text"><MyHighlighter search={searchTerm}>{loadbalancer.id}</MyHighlighter></span>
            </React.Fragment>
          }
      </td>
      <td>{loadbalancer.description}</td>
      <td><StateLabel status={loadbalancer.operating_status} /></td>
      <td><StateLabel status={loadbalancer.provisioning_status} /></td>
      <td>
        <StaticTags tags={loadbalancer.tags} />
      </td>
      <td className="snug-nowrap">
        {loadbalancer.subnet && 
          <React.Fragment>
            <p className="list-group-item-text" data-is-from-cache={loadbalancer.subnet_from_cache}>{loadbalancer.subnet.name}</p>
          </React.Fragment>
        }
        {loadbalancer.vip_address && 
          <React.Fragment>
            <p className="list-group-item-text">
              <i className="fa fa-desktop fa-fw"/>
              {loadbalancer.vip_address}
            </p>
          </React.Fragment>
        }
        {loadbalancer.floating_ip && 
          <React.Fragment>
            <p className="list-group-item-text">
              <i className="fa fa-globe fa-fw"/>
              {loadbalancer.floating_ip.floating_ip_address}
            </p>
          </React.Fragment>
        }
      </td>
      <td> 
        <LbPopover  popoverId={"listener-popover-"+loadbalancer.id} 
                    buttonName={listenerIds.length} 
                    title={<React.Fragment>Listeners<Link to={`/listeners/`} style={{float: 'right'}}>Show all</Link></React.Fragment>}
                    content={
          listenerIds.length>0 ?
          listenerIds.map( (id, index) =>
            <div key={id}>
              { loadbalancer.cached_listeners[id] ?
                <React.Fragment>
                  <div className="row">
                    <div className="col-md-12">
                      <Link to={`/listeners/${id}/show`}>
                        {loadbalancer.cached_listeners[id].name || id}
                       </Link>
                    </div>
                  </div>
                  {loadbalancer.cached_listeners[id].name && 
                    <div className="row">
                      <div className="col-md-12 text-nowrap">
                      <small className="info-text">{id}</small>
                      </div>                
                    </div>
                  }
                  <div className="row">
                    <div className="col-md-12">
                      <b>Description:</b> {loadbalancer.cached_listeners[id].payload.description}
                    </div>
                  </div> 
                  <div className="row">
                    <div className="col-md-12">
                      <b>Protocol:</b> {loadbalancer.cached_listeners[id].payload.protocol}
                    </div>
                  </div>              
                  <div className="row">
                    <div className="col-md-12">
                      <b>Protocol Port:</b> {loadbalancer.cached_listeners[id].payload.protocol_port}
                    </div>
                  </div>
                </React.Fragment>
                :
                <div className="row">
                  <div className="col-md-12 text-nowrap">
                    <Link to={`/listeners/${id}/show`}>
                      <small>{id}</small>
                    </Link>
                  </div>                
                </div>                
              }
              { index === listenerIds.length - 1 ? "" : <hr/> }
            </div>
          )
          :
          <p>No listeners found</p>
        } />
      </td>
      <td>
        <LbPopover  popoverId={"pools-popover-"+loadbalancer.id} 
                    buttonName={poolIds.length} 
                    title={<React.Fragment>Pools<Link to={`/pools/`} style={{float: 'right'}}>Show all</Link></React.Fragment>}
                    content={
              poolIds.length>0 ?
                poolIds.map( (id, index) =>
                <div key={id}>
                  { loadbalancer.cached_pools[id] ?
                    <React.Fragment>
                      <div className="row">
                        <div className="col-md-12">
                        <Link to={`/pools/${id}/show`}>
                          {loadbalancer.cached_pools[id].name || id}
                        </Link>
                        </div>
                      </div>
                      {loadbalancer.cached_pools[id].name && 
                        <div className="row">
                          <div className="col-md-12 text-nowrap">
                          <small className="info-text">{id}</small>
                          </div>                
                        </div>
                      }
                      <div className="row">
                        <div className="col-md-12">
                          <b>Description:</b> {loadbalancer.cached_pools[id].payload.description}
                        </div>
                      </div> 
                      <div className="row">
                        <div className="col-md-12">
                          <b>Algorithm:</b> {loadbalancer.cached_pools[id].payload.lb_algorithm}
                        </div>
                      </div>  
                      <div className="row">
                        <div className="col-md-12">
                          <b>Protocol:</b> {loadbalancer.cached_pools[id].payload.protocol}
                        </div>
                      </div>   
                    </React.Fragment>
                    :
                    <div className="row">
                      <div className="col-md-12 text-nowrap">
                        <Link to={`/pools/${id}/show`}>
                          <small>{id}</small>
                        </Link> 
                      </div>                
                    </div> 
                  }
                  { index === poolIds.length - 1 ? "" : <hr/> }
                </div>
                )
              :
              <p>No pools found</p>
            } />
      </td>
    </tr>
  )
})
LoadbalancerItem.displayName = 'LoadbalancerItem';

export default LoadbalancerItem;