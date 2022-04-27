const display = (msg) => (
  <React.Fragment>
    <span className='spinner' /> {msg}...
  </React.Fragment>
);

export default class AccountDeleter extends React.Component {
  state = {
    lastDeleteResponse: null,
    //counts manifests that were deleted since `lastDeleteResponse`
    deletedManifestsCount: 0,
  };

  componentDidMount() {
    this.tryDelete();
  }

  tryDelete() {
    this.props.deleteAccount(this.props.accountName)
      .then(response => this.processDeleteResponse(response))
      .catch(error => this.props.handleDoneDeleting(false));
  }

  processDeleteResponse(response) {
    //are we there yet?
    if (response.success) {
      this.props.handleDoneDeleting(true);
      return;
    }

    //use response to render progress indication
    this.setState({
      ...this.state,
      lastDeleteResponse: response.body,
      deletedManifestsCount: 0,
    });

    //are there any manifests left to delete?
    if (response.body.remaining_manifests) {
      const { next: manifests } = response.body.remaining_manifests;
      const promises = manifests.map(manifest => (
        this.props.deleteManifest(manifest.repository, manifest.digest)
          .then(() => {
            this.setState({
              ...this.state,
              deletedManifestsCount: this.state.deletedManifestsCount + 1,
            });
          })
      ));
      //once this batch of manifests is deleted, try deleting the account again
      //- if there are more manifests, this gives us the next batch of
      //manifests to delete)
      Promise.all(promises)
        .then(() => this.tryDelete())
        .catch(() => this.props.handleDoneDeleting(false));
      return;
    }

    //if no manifests are left to be deleted, we just need to wait for blob
    //sweeping to go through
    setTimeout(() => this.tryDelete(), 10000);
  }

  render() {
    //phase 0: before first DELETE request resolves
    const resp = this.state.lastDeleteResponse;
    if (!resp) {
      return display('Preparing deletion');
    }

    //phase 1: deleting manifests
    if (resp.remaining_manifests) {
      const manifestCount = resp.remaining_manifests.count - this.state.deletedManifestsCount;
      return display(`Deleting images (${manifestCount} remaining)`);
    }

    //phase 2: waiting for blobs to be deleted
    const blobCount = (resp.remaining_blobs || {}).count || 0;
    return display(`Waiting for blob deletion (${blobCount} remaining)`);
  }
}
