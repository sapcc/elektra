import React from "react"
import { connect } from "react-redux"

import "./clusters/setup"
import {
  ReactConfirmDialog,
  ReactInfoDialog,
  ReactErrorDialog,
} from "../lib/dialogs"
import ReactModal from "../lib/modal"

import ClusterList from "./clusters/list"
import NewClusterModal from "./clusters/new"
import EditClusterModal from "./clusters/edit"
import SetupInfoModal from "./clusters/setup"

const modalComponents = {
  NEW_CLUSTER: NewClusterModal,
  EDIT_CLUSTER: EditClusterModal,
  SETUP_INFO: SetupInfoModal,
  // eslint-disable-next-line no-undef
  CONFIRM: ReactConfirmDialog,
  // eslint-disable-next-line no-undef
  INFO: ReactInfoDialog,
  // eslint-disable-next-line no-undef
  ERROR: ReactErrorDialog,
}

// eslint-disable-next-line no-undef
const Modal = ReactModal.Container("modals", modalComponents)

// eslint-disable-next-line react/prop-types
const App = ({ kubernikusBaseUrl }) => (
  <div>
    <ClusterList kubernikusBaseUrl={kubernikusBaseUrl} />
    <Modal />
  </div>
)

export default connect()(App)
