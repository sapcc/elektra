//export default (props) => <div>TEST</div>

import Datetime from 'react-datetime'
import moment from 'moment'
import EventItem from '../../containers/events/item'
import EventItemDetail from './item_details'
import Pagination from '../../containers/shared/pagination'
import { isEmpty } from 'lib/tools/helpers'

const isValidDate = (date) =>
  // do not allow dates that are in the future
  !moment(date).isAfter()

export default ({
  events,
  isFetching,
  loadEvents,
  handleStartTimeChange,
  handleEndTimeChange,
  handleFilterTypeChange,
  handleFilterTermChange,
  handleClearFilters,
  filterStartTime,
  filterEndTime,
  filterType,
  filterTerm,
  attributeValues,
  isFetchingAttributeValues,
  offset,
  limit,
  total,
  error
}) =>

  <div>
    <div className='toolbar toolbar-controlcenter'>
      <label>Filter:</label>
      <div className='inputwrapper'>
        <select
          name='filterType'
          className='form-control'
          value={filterType}
          onChange={(e) => handleFilterTypeChange(e.target.value)}>

          <option value=''>Select attribute</option>
          <option value='observer_type'>Source</option>
          <option value='action'>Action</option>
          <option value='target_type'>Resource Type</option>
          <option value='target_id'>Resource ID</option>
          <option value='initiator_id'>Initiator/User ID</option>
          <option value='initiator_type'>Initiator Type</option>
          <option value='outcome'>Result</option>
        </select>
      </div>
      <div className='inputwrapper'>
        { (!/target_id|initiator_id/.test(filterType) && attributeValues[filterType] && attributeValues[filterType].length > 0) ?
          <select
            name='filterTerm'
            className='form-control filter-term'
            value={filterTerm}
            onChange={(e) => handleFilterTermChange(e.target.value, 0)}>
            <option value=''>Select</option>
            {attributeValues[filterType].map((attribute) =>
              <option value={attribute} key={`filterTerm_${attribute}`}>
                {attribute}
              </option>
            )}
          </select>
          :
          <input
            name='filterTerm'
            className='form-control filter-term'
            value={filterTerm}
            placeholder='Enter lookup value'
            disabled={isEmpty(filterType) || isFetchingAttributeValues}
            onChange={(e) => handleFilterTermChange(e.target.value, 500)}/>
        }
      </div>
      <span className='toolbar-input-divider'/>

      <label>Time range:</label>
      <Datetime
        value={filterStartTime}
        inputProps={{placeholder: 'Select start time'}}
        isValidDate={isValidDate}
        onChange={(e) => handleStartTimeChange(e)}/>
      <span className='toolbar-input-divider'>&ndash;</span>
      <Datetime
        value={filterEndTime}
        inputProps={{placeholder: 'Select end time'}}
        isValidDate={isValidDate}
        onChange={(e) => handleEndTimeChange(e)}/>

      { (filterTerm || filterEndTime || filterStartTime) &&
        <a className='clear-all' href='#' onClick={(e) => {e.preventDefault(); handleClearFilters()}}>
          <i className='fa fa-times-circle'></i>Clear filters
        </a>
      }
    </div>

    <table className='table'>
      <thead>
        <tr>
          <th className='icon-cell'></th>
          <th>Time</th>
          <th>Source</th>
          <th>Action</th>
          <th>Target Resource</th>
          <th className='user-cell'>Initiator/User</th>
        </tr>
      </thead>

      { error ?
        <tbody><tr><td colSpan='6'>{error}</td></tr></tbody>
        :
        ( events ?
          events.map((event) =>
            <tbody key={event.id}>
              <EventItem event={event}/>
              {event.detailsVisible && <EventItemDetail event={event}/>}
            </tbody>
          )
          :
          <tbody><tr><td colSpan='6'>No events found</td></tr></tbody>
        )
      }
      { isFetching &&
          <tbody><tr><td colSpan='6'><span className='spinner'/></td></tr></tbody>
      }
    </table>
    <Pagination offset={offset} limit={limit} total={total}/>
  </div>
