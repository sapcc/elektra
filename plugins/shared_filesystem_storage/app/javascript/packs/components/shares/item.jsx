import { Link } from 'react-router-dom';

export default ({
  policy,
  share,
  shareNetwork,
  shareRules,
  handleDelete
}) => {
  // <a href='#' onClick={(e) => { e.preventDefault(); handleShow(share.id)}} >
  //   {share.name || share.id}
  // </a>

  return (
    <tr className={ share.isDeleting ? 'updating' : ''}>
      <td>
        <Link to={`/shares/${share.id}`}>{share.name || share.id}</Link>
      </td>
      <td>{share.availability_zone}</td>
      <td>{share.share_proto}</td>
      <td>{(share.size || 0) + ' GB'}</td>
      <td>
        { share.status == 'creating' &&
          <span className='spinner'></span>
        }
        {share.status}
      </td>
      <td>
        { shareNetwork ? (
          <span>
            {shareNetwork.name}
            { shareNetwork.cidr &&
              <span className='info-text'>{" "+shareNetwork.cidr}</span>
            }
            { shareRules &&
              (
                shareRules.isFetching ? (
                  <span className='spinner'></span>
                ) : (
                  <span>
                    <br/>
                    { shareRules.items.map( (rule) =>
                      <small key={rule.id}
                        data-toggle="tooltip" data-placement="right"
                        title="Access Level: {if rule.access_level=='ro' then 'read only' else if 'rw' then 'read/write' else rule.access_level}"
                        className="#{if rule.access_level == 'rw' then 'text-success' else 'text-info'}"
                        ref={(el) => $(el).tooltip()}>
                        <i className="fa fa-fw fa-#{if rule.access_level == 'rw' then 'pencil-square' else 'eye'}"></i>
                        {rule.access_to}
                      </small>
                    )}
                  </span>
                )
              )}
          </span>) : (
          <span className='spinner'></span>
        )}
      </td>
      <td className="snug">
        { (share.permissions.delete || share.permissions.update) &&
          <div className='btn-group'>
            <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
              <i className='fa fa-cog'></i>
            </button>
            <ul className='dropdown-menu dropdown-menu-right' role="menu">
              { share.permissions.delete &&
                <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(share.id) } }>Delete</a></li>
              }
              { share.permissions.update &&
                <li><Link to={`/shares/${share.id}/edit`}>Edit</Link></li>
              }
              { share.permissions.update && share.status=='available' &&
                <li><a href='#' onClick={(e) => {e.preventDefault(); handleSnapshot(share.id)}}>Create Snapshot</a></li>
              }
              { share.permissions.update && share.status=='available' &&
                <li>
                  {/*
                    <a href='#' onClick={(e) => {e.preventDefault(); handleAccessControl(share.id,share.share_network_id)}}>Access Control</a>
                  */}
                  <Link to={`/shares/${share.id}/access-control`}>Access Control</Link>
                </li>
              }
            </ul>
          </div>
        }
      </td>
    </tr>
  )
}
