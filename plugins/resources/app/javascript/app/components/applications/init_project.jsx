/* eslint no-console:0 */
import Loader from '../../containers/loader';

export default (props) => {
  const { clusterId, domainId, projectId, flavorData } = props;
  const scopeData = { clusterID: clusterId, domainID: domainId, projectID: projectId };
  const rootProps = { flavorData, scopeData };

  return <Loader scopeData={scopeData} isModal={true}>
    <div className='modal-body'>
      <p>Hello World</p>
    </div>
  </Loader>;
};
