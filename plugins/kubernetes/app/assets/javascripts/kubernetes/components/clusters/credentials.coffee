{ div,button,p,a } = React.DOM
{ connect } = ReactRedux
{ updateClusterForm, submitClusterForm } = kubernetes


Credentials = ({
  close,
  clusterForm,
  handleSubmit,
  handleChange
}) ->

  div null,
    div className: 'modal-body',
      p null,
        "In order to interact with your cluster you'll need the correct credentials. We have generated a kubeconfig file for you which contains all the necessary credentials."
      p null,
        "More information about kubeconfig files can be found "
        a href: 'https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/', 'in the official kubernetes documentation'
      button className: 'btn btn-primary', onClick: onClick: ((e) => e.preventDefault(); downloadCredentials()), 'Download kubeconfig'



    div className: 'modal-footer',
      button role: 'close', type: 'button', className: 'btn btn-default', onClick: close, 'Close'

Credentials = connect(
  (state) ->
    {}

  (dispatch) ->
    downloadCredentials: () -> dispatch(downloadCredentials())


)(Credentials)

kubernetes.CredentialsModal = ReactModal.Wrapper('Cluster Credentials', Credentials,
  large: true,
  closeButton: false,
  static: true
)
