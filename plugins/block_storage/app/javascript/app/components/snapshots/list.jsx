import {Link} from 'react-router-dom';
import {DefeatableLink} from 'lib/components/defeatable_link';
import {Popover, OverlayTrigger, Tooltip} from 'react-bootstrap';
import {TransitionGroup, CSSTransition} from 'react-transition-group';
import {FadeTransition} from 'lib/components/transitions';
import {policy} from 'policy';
import { SearchField } from 'lib/components/search_field';
import Item from './item';
import { AjaxPaginate } from 'lib/components/ajax_paginate';

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
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    if (!props.active)
      return;
    props.loadSnapshotsOnce()
  }

  render() {
    const items = this.props.snapshots.items || []

    if(this.props.snapshots.isFetching) {
      return <React.Fragment><span className='spinner'></span> Loading...</React.Fragment>
    } else if (items.length == 0) {
      return <span>No snapshots found.</span>
    }
    return (
      <React.Fragment>
        <div className='toolbar'>
          <SearchField onChange={(term) => this.props.searchSnapshots(term)} placeholder='name, ID, format or status' text='Searches by name, ID, format or status in visible snapshots list only.
            Entering a search term will automatically start loading the next pages
            and filter the loaded items using the search term. Emptying the search
            input field will show all currently loaded items.'/>
        </div>

        <table className='table snapshots'>
          <thead>
            <tr>
              <th>Snapshot</th>
              <th>Description</th>
              <th>Size(GB)</th>
              <th>Source Volume</th>
              <th>Status</th>
              <th className='snug'></th>
            </tr>
          </thead>
            <TransitionGroup component="tbody">
              { items.map((snapshot, index) => !snapshot.isHidden &&
                <TableRowFadeTransition key={index}>
                  <Item snapshot={snapshot}/>
                </TableRowFadeTransition>
              )}
            </TransitionGroup>
        </table>
      </React.Fragment>
    )
  }
}
