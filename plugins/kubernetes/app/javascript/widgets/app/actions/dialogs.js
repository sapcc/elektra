/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactModal from "../lib/modal"

const showConfirmDialog = ({
  title,
  message,
  confirmCallback,
  cancelCallback,
}) => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "CONFIRM",
  modalProps: { title, message, confirmCallback, cancelCallback },
})

const showErrorDialog = ({ title, message }) => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "ERROR",
  modalProps: { title, message },
})

const showInfoDialog = ({ title, message }) => ({
  type: ReactModal.SHOW_MODAL,
  modalType: "INFO",
  modalProps: { title, message },
})

// export
export { showConfirmDialog, showErrorDialog, showInfoDialog }
