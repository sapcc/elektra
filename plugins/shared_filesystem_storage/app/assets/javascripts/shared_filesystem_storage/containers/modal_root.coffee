# require components/floating_ips/components/AddTodoModal
# require components/floating_ips/components/ShowTodosModal

{ div } = React.DOM
{ connect } = ReactRedux

MODAL_COMPONENTS =
  'SHOW_TODOS': window.ShowTodosModal
  'ADD_TODO': window.AddTodoModal

ModalRoot = ({ modals }) ->
  return null unless (modals and modals.length)
  div null,
    for modal in modals
      if modal.modalType and MODAL_COMPONENTS[modal.modalType]
        React.createElement MODAL_COMPONENTS[modal.modalType], key: modal.modalType, modalType: modal.modalType, modalProps: modal.modalProps

ModalRoot = connect(
  (state) -> modals: state.modals
)(ModalRoot)

shared_filesystem_storage.ModalRoot = ModalRoot
