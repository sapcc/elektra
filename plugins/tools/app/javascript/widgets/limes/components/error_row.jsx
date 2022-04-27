import { PrettyDate } from 'lib/components/pretty_date';

export default (props) => {
  const { service_type: serviceType, checked_at: checkedAt, message: errorMessage } = props.error;
  const { id: projectID, name: projectName } = props.error.project;
  const { id: domainID, name: domainName } = props.error.project.domain;
  const projectCount = props.error.affected_projects || 1;

  return (
    <React.Fragment>
      <tr>
        <td className='col-md-2'>
          {serviceType}
        </td>
        <td className='col-md-2'>
          <PrettyDate date={checkedAt} />
        </td>
        <td className='col-md-8'>
          <a href={`/_/${projectID}/home`} target='_blank' title='Jump to project'>{domainName}/{projectName}</a>
          {projectCount > 1 && (
            <React.Fragment>
              {` and `}
              <strong>{projectCount-1} more projects</strong>
            </React.Fragment>
          )}
          <div className='text-small text-muted'>{projectID}</div>
        </td>
      </tr>
      <tr className='explains-previous-line'>
        <td colSpan='3' className='text-danger'>{errorMessage}</td>
      </tr>
    </React.Fragment>
  );
};
