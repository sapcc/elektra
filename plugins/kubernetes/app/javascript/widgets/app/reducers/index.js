import clusters from "./clusters"
import clusterForm from "./cluster_form"
import info from "./info"
import metaData from "./meta_data"
import ReactModal from "../lib/modal"

import { combineReducers } from "redux"

const AppReducers = combineReducers({
  modals: ReactModal.Reducer,
  clusters: clusters,
  clusterForm: clusterForm,
  metaData: metaData,
  info: info,
})

export default AppReducers
