/* eslint no-console:0 */
import { BrowserRouter, Route, Redirect } from "react-router-dom"
import { scope } from "lib/ajax_helper"

import Tabs from "./tabs"

import Volumes from "../containers/volumes/list"
import Snapshots from "../containers/snapshots/list"
import ShowVolumeModal from "../containers/volumes/show"
import NewVolumeModal from "../containers/volumes/new"
import CloneVolumeModal from "../containers/volumes/clone_volume"
import EditVolumeModal from "../containers/volumes/edit"
import AttachVolumeModal from "../containers/volumes/attach"
import ResetVolumeStatusModal from "../containers/volumes/reset_status"
import ExtendVolumeSizeModal from "../containers/volumes/extend_size"
import VolumeToImageModal from "../containers/volumes/to_image"

import ShowSnapshotModal from "../containers/snapshots/show"
import NewSnapshotModal from "../containers/snapshots/new"
import EditSnapshotModal from "../containers/snapshots/edit"
import ResetSnapshotStatusModal from "../containers/snapshots/reset_status"
import NewSnapshotVolumeModal from "../containers/snapshots/new_volume"

const tabsConfig = [
  { to: "/volumes", label: "Volumes", component: Volumes },
  { to: "/snapshots", label: "Volume Snapshots", component: Snapshots },
]

// render all components inside a hash router
export default (props) => {
  //console.log(props)
  return (
    <BrowserRouter basename={`${window.location.pathname}?r=`}>
      <div>
        {/* redirect root to os_images tab */}
        {policy.isAllowed("block_storage:volume_list") && (
          <Route exact path="/" render={() => <Redirect to="/volumes" />} />
        )}
        <Route
          path="/:activeTab"
          children={({ match, location, history }) =>
            React.createElement(
              Tabs,
              Object.assign({}, { match, location, history, tabsConfig }, props)
            )
          }
        />

        {policy.isAllowed("block_storage:volume_get") && (
          <React.Fragment>
            <Route exact path="/volumes/:id/show" component={ShowVolumeModal} />
            <Route
              exact
              path="/snapshots/volumes/:id/show"
              component={ShowVolumeModal}
            />
          </React.Fragment>
        )}
        {policy.isAllowed("image:image_create") && (
          <Route
            exact
            path="/volumes/:id/images/new"
            component={VolumeToImageModal}
          />
        )}
        {policy.isAllowed("block_storage:volume_create", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <React.Fragment>
            <Route exact path="/volumes/new" component={NewVolumeModal} />
            <Route exact path="/volumes/:id/new" component={CloneVolumeModal} />
          </React.Fragment>
        )}
        {policy.isAllowed("block_storage:snapshot_create", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <Route
            exact
            path="/snapshots/:snapshot_id/volumes/new"
            component={NewSnapshotVolumeModal}
          />
        )}
        {policy.isAllowed("block_storage:volume_update", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <Route exact path="/volumes/:id/edit" component={EditVolumeModal} />
        )}
        {policy.isAllowed("compute:attach_volume", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <Route
            exact
            path="/volumes/:id/attachments/new"
            component={AttachVolumeModal}
          />
        )}
        {policy.isAllowed("block_storage:volume_reset_status") && (
          <Route
            exact
            path="/volumes/:id/reset-status"
            component={ResetVolumeStatusModal}
          />
        )}
        {policy.isAllowed("block_storage:volume_extend_size") && (
          <Route
            exact
            path="/volumes/:id/extend-size"
            component={ExtendVolumeSizeModal}
          />
        )}

        {policy.isAllowed("block_storage:snapshot_get") && (
          <Route
            exact
            path="/snapshots/:id/show"
            component={ShowSnapshotModal}
          />
        )}
        {policy.isAllowed("block_storage:snapshot_update", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <Route
            exact
            path="/snapshots/:id/edit"
            component={EditSnapshotModal}
          />
        )}
        {policy.isAllowed("block_storage:snapshot_create", {
          target: { scoped_domain_name: scope.domain },
        }) && (
          <Route
            exact
            path="/volumes/:volume_id/snapshots/new"
            component={NewSnapshotModal}
          />
        )}
        {policy.isAllowed("block_storage:snapshot_reset_status") && (
          <Route
            exact
            path="/snapshots/:id/reset-status"
            component={ResetSnapshotStatusModal}
          />
        )}
      </div>
    </BrowserRouter>
  )
}
