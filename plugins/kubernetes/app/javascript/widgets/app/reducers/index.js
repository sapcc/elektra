import clusters from "./clusters.coffee"
import clusterForm from "./cluster_form.coffee"
import info from "./info.coffee"
import metaData from "./meta_data.coffee"
import "core/components/modal"

import { combineReducers } from "redux"

const AppReducers = combineReducers({
  modals: ReactModal.Reducer,
  clusters: clusters,
  clusterForm: clusterForm,
  metaData: metaData,
  info: info,
})

export default AppReducers
