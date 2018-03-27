import { Link } from 'react-router-dom';
import { policy } from 'policy';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';
import { PrettyDate } from 'lib/components/pretty_date';
import { PrettySize } from 'lib/components/pretty_size';

export const ImageIcon = ({image}) => {
  const tooltip = <Tooltip id='iconTooltip'>{image.visibility}</Tooltip>;
  let iconType;
  switch(image.visibility) {
    case 'public': iconType='fa-cloud'; break;
    case 'private': iconType='fa-lock'; break;
    case 'community': iconType='fa-users'; break;
    case 'shared': iconType='fa-share'; break;
  }

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}>
      <i className={`text-primary fa fa-fw ${iconType}`}/>
    </OverlayTrigger>
  )
}

export const OwnerIcon = () => {
  const tooltip = <Tooltip id='iconTooltip'>Owned by this project</Tooltip>;

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}>
      <i className='text-primary fa fa-fw fa-user'/>
    </OverlayTrigger>
  )
}

export default (props) => {
  let { image } = props
  const canCreateInstance =  policy.isAllowed(
    "compute:instance_create",
    { target: {
      project: {parent_id: props.project_parent_id},
      scoped_domain_name: props.scoped_domain_name}
    }
  )

  return(
    <tr className={ image.isDeleting ? 'updating' : ''}>
      <td className="snug">
        <ImageIcon image={image}/>
        {policy.isAllowed("image:image_owner", {image}) && <OwnerIcon/>}
      </td>
      <td>
        <Link to={`/os-images/${props.activeTab}/${image.id}/show`}>{image.name || image.id}</Link>
        { image.name && <span className='info-text'><br/>{image.id}</span> }
      </td>
      <td>{image.disk_format}</td>
      <td><PrettySize size={image.size}/></td>
      <td><PrettyDate date={image.created_at}/></td>
      <td>{image.status}</td>
      <td className="snug">
        { (canCreateInstance || policy.isAllowed("image:image_unpublish")) &&
          <div className='btn-group'>
            <button
              className='btn btn-default btn-sm dropdown-toggle'
              type='button'
              data-toggle='dropdown'
              aria-expanded={true}>
              <i className='fa fa-cog'></i>
            </button>
            <ul className='dropdown-menu dropdown-menu-right' role='menu'>
              { canCreateInstance &&
                <li>
                  <a
                    href={`${props.launchInstanceUrl}?image_id=${image.id}`}
                    data-modal>
                    Launch Instance
                  </a>
                </li>
              }
              { props.activeTab == 'suggested' && image.visibility == 'shared' &&
                <li><a href='#' onClick={(e) => props.handleAccept(image.id)}>Accept</a></li>
              }
              { props.activeTab == 'suggested' && image.visibility == 'shared' &&
                <li><a href='#' onClick={(e) => props.handleReject(image.id)}>Reject</a></li>
              }
              { props.activeTab == 'available' && (image.visibility == 'shared' || image.visibility == 'private') &&
                <li><Link to={`/os-images/${props.activeTab}/${image.id}/members`}>Access Control</Link></li>
              }
              { image.visibility == 'public' && policy.isAllowed("image:image_unpublish") &&
                <li><a href='#' onClick={() => props.handleUnpublish(image.id)}>Unpublish</a></li>
              }
              { image.visibility != 'public' && policy.isAllowed("image:image_publish") &&
                <li><a href='#' onClick={(e) => props.handlePublish(image.id)}>Publish</a></li>
              }
              { policy.isAllowed("image:image_delete", {image}) &&
                <li><a href='#' onClick={(e) => props.handleDelete(image.id)}>Delete</a></li>
              }
            </ul>
          </div>
        }
      </td>
    </tr>
  )
}
