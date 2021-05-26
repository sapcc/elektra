import { connect } from "react-redux"
import ReplicaList from "../../components/replicas/list"
import {
  fetchReplicasIfNeeded,
  deleteReplica,
  reloadReplica,
} from "../../actions/replicas"

export default connect(
  (state) => ({
    replicas: state.replicas.items,
    shares: state.shares,
    isFetching: state.replicas.isFetching,
  }),
  (dispatch) => ({
    loadReplicasOnce: () => dispatch(fetchReplicasIfNeeded()),
    handleDelete: (replicaId) => dispatch(deleteReplica(replicaId)),
    reloadReplica: (replicaId) => dispatch(reloadReplica(replicaId)),
  })
)(ReplicaList)
