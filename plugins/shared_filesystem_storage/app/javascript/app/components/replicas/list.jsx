import ReplicaItem from "./item"

export default class ReplicaList extends React.Component {
  constructor(props) {
    super(props)
    this.share = this.share.bind(this)
  }

  componentDidMount() {
    if (this.props.active) this.props.loadReplicasOnce()
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if (nextProps.active) this.props.loadReplicasOnce()
  }

  share(replica) {
    if (this.props.shares.isFetching) return "loading"
    return this.props.shares.items.find((i) => i.id == replica.share_id)
  }

  render() {
    if (this.props.isFetching) {
      return (
        <div>
          <span className="spinner"></span>Loading...
        </div>
      )
    }

    return (
      <table className="table replicas">
        <thead>
          <tr>
            <th>ID</th>
            <th>Source Share</th>
            <th>Replica State</th>
            <th>Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {this.props.replicas.length === 0 ? (
            <tr>
              <td colSpan="5">No Replicas found.</td>
            </tr>
          ) : (
            this.props.replicas.map((replica) => (
              <ReplicaItem
                key={replica.id}
                replica={replica}
                share={this.share(replica)}
                handleDelete={this.props.handleDelete}
                reloadReplica={this.props.reloadReplica}
                promoteReplica={() => this.props.promoteReplica(replica.id)}
                resyncReplica={() => this.props.resyncReplica(replica.id)}
              />
            ))
          )}
        </tbody>
      </table>
    )
  }
}
