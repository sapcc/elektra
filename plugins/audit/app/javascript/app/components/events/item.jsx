import moment from 'moment'

export default ({event, toggleDetails}) => {
  let showDetailsClassName = event.detailsVisible ? 'fa fa-caret-down' : 'fa fa-caret-right'
  return (
    <tr>
      <td>
        <a href='#' onClick={(e) => { e.preventDefault(); toggleDetails(event)}}>
          <i className={showDetailsClassName}></i>
        </a>
      </td>
      <td>{ moment(event.eventTime).format("YYYY-MM-DD, HH:mm:ssZZ")}</td>
      <td>{event.observer.typeURI}</td>
      <td>{event.action}</td>
      <td className='big-data-cell'>
        {event.target.typeURI}
        <br/>
        <span className='resource-id'>{event.target.id}</span>
      </td>
      <td className='big-data-cell'>
        { // in case we decide enrich the events with names in the hermes backend (not implemented)
          // if event.initiator.name && event.initiator.name.length > 0
          // event.initiator.name
          // else
        }
        <div>{event.initiator.name}</div>
        <span className='resource-id'>{event.initiator.id}</span>
      </td>
    </tr>
  )
}
