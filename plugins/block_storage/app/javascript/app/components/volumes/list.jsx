import {Link} from 'react-router-dom';
import {DefeatableLink} from 'lib/components/defeatable_link';
import {Popover, OverlayTrigger, Tooltip} from 'react-bootstrap';
import {TransitionGroup, CSSTransition} from 'react-transition-group';
import {FadeTransition} from 'lib/components/transitions';
import {policy} from 'policy';
import { SearchField } from 'lib/components/search_field';
import Item from './item';
import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { scope } from 'ajax_helper'

const TableRowFadeTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={200} classNames="css-transition-fade">
  {children}
</CSSTransition>);

export default class List extends React.Component {
  state = {
  }

  componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    this.props.listenToVolumes()
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    if (!props.active)
      return;
    props.loadVolumesOnce()
  }

  filterItems = () => {
    let {items = [], searchTerm} = this.props.volumes
    if(!searchTerm) return items;

    // filter items
    const regex = new RegExp(searchTerm.trim(), "i");

    return items.filter((i) =>
      `${i.id} ${i.name} ${i.description} ${i.availability_zone} ${i.size} ${i.status}`.search(regex) >= 0
    )
  }


  render() {
    const {hasNext, isFetching, searchTerm} = this.props.volumes
    const items = this.filterItems()
    const canCreate = policy.isAllowed("block_storage:volume_create",{target:{scoped_domain_name: scope.domain}})

    return (
      <React.Fragment>
        {(this.props.volumes.items.length>5 || canCreate) &&
          <div className='toolbar'>
            { this.props.volumes.items.length>5 &&
              <SearchField
                onChange={(term) => this.props.search(term)}
                placeholder='name, ID, format or status' text='Searches by name, ID, format or status in visible volumes list only.
                Entering a search term will automatically start loading the next pages
                and filter the loaded items using the search term. Emptying the search
                input field will show all currently loaded items.'/>
            }
            {canCreate &&
              <div className="main-buttons">
                <DefeatableLink
                  to='/volumes/new'
                  className='btn btn-primary'>
                  Create New
                </DefeatableLink>
              </div>
            }
          </div>
        }

        <table className='table volumes'>
          <thead>
            <tr>
              <th></th>
              <th>Volume Name</th>
              <th>Availability Zone</th>
              <th>Description</th>
              <th>Size(GB)</th>
              <th>Attached to</th>
              <th>Status</th>
              <th className='snug'></th>
            </tr>
          </thead>

          <tbody>
            { items && items.length>0 ?
              items.map( (volume, index) =>
                <Item
                  volume={volume}
                  key={index}
                  searchTerm={searchTerm}
                  reloadVolume={this.props.reloadVolume}
                  deleteVolume={this.props.deleteVolume}
                  detachVolume={this.props.detachVolume}
                  forceDeleteVolume={this.props.forceDeleteVolume}/>
              )
              :
              <tr>
                <td colSpan="7">{ isFetching ? <span className='spinner'/> : 'No volumes found.' }</td>
              </tr>
            }
          </tbody>
        </table>

        <AjaxPaginate hasNext={hasNext} isFetching={isFetching} onLoadNext={this.props.loadNext}/>
      </React.Fragment>
    )
  }
}
