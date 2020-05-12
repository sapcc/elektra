import { DataTable } from 'lib/components/datatable';

import { Scope } from '../../scope';
import { Unit, valueWithUnit } from '../../unit';

const columns = [
  { key: 'id', label: 'Cluster', sortStrategy: 'text',
    sortKey: props => props.metadata.id || '' },
  { key: 'domains_quota', label: 'Total domain quota', sortStrategy: 'numeric',
    sortKey: props => props.resource.domains_quota || 0 },
  { key: 'usage', label: 'Usage', sortStrategy: 'numeric',
    sortKey: props => props.resource.usage || 0 },
  { key: 'burst_usage', label: 'Thereof burst', sortStrategy: 'numeric',
    sortKey: props => props.resource.burst_usage || 0 },
  { key: 'actions', label: 'Actions' },
];

export default class DetailsClusters extends React.Component {
  state = {
    //This contains the quota/usage data for the clusters.
    clusters: null,
    isFetching: false,
  };

  UNSAFE_componentWillReceiveProps(nextProps) {
    this.fetchClusters(nextProps);
  }
  componentDidMount() {
    this.fetchClusters(this.props);
  }

  //This gets called once to initialize the list of subscopes.
  fetchClusters = (props) => {
    //do this only once
    if (this.state.subscopes || this.state.isFetching) {
      return;
    }

    this.setState({
      ...this.state,
      isFetching: true,
    });
    props.listClusters(props.category.serviceType, props.resource.name)
      .then(this.receiveClusters)
      .catch(response => props.handleAPIErrors(response.errors));
  }

  //This gets called by fetchClusters() on success.
  receiveClusters = (data) => {
    const clusters = [];
    //transform the nested structure of Limes' JSON into something flatter,
    //similar to app/reducers/limes.js
    for (const clusterData of data.clusters) {
      const { services: serviceList, ...metadata } = clusterData;
      if (serviceList.length == 0) {
        continue;
      }
      const { resources: resourceList, ...serviceData } = serviceList[0];
      if (resourceList.length == 0) {
        continue;
      }
      metadata.isSelected = data.current_cluster == metadata.id;
      clusters.push({
        metadata: metadata,
        service:  serviceData,
        resource: resourceList[0],
      });
    }

    this.setState({
      ...this.state,
      clusters: clusters,
      isFetching: false,
    });
  }

  renderRow(cluster) {
    const { isSelected, id: clusterID } = cluster.metadata;
    const unit = new Unit(cluster.resource.unit);
    const scope = new Scope({clusterID});

    return <tr key={clusterID}>
      <td className='col-md-3'>{clusterID}</td>
      <td className='col-md-3'>
        {valueWithUnit(cluster.resource.domains_quota || 0, unit)}
      </td>
      <td className='col-md-2'>
        {valueWithUnit(cluster.resource.usage || 0, unit)}
      </td>
      <td className='col-md-2'>
        {valueWithUnit(cluster.resource.burst_usage || 0, unit)}
      </td>
      <td className='col-md-2'>
        <a href={scope.elektraUrlPath()} target='_blank' className='btn btn-default btn-sm'
          disabled={isSelected} title={isSelected ? 'Go to Resource Management for this cluster in a new tab' : ''}>
          {isSelected ? 'Selected' : 'Jump'}
        </a>
      </td>
    </tr>;
  }

  render() {
    const { clusters, isFetching } = this.state;
    if (isFetching) {
      return <p>
        <span className='spinner'/> Loading clusters...
      </p>;
    }

    const rows = (this.state.clusters || []).map(cluster => this.renderRow(cluster));
    return <DataTable columns={columns} children={rows} />;
  }
}
