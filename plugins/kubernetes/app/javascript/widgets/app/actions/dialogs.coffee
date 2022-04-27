import * as constants from "../constants"
import "../lib/modal"

showConfirmDialog = ({title, message, confirmCallback, cancelCallback}) ->
  type:       ReactModal.SHOW_MODAL,
  modalType: 'CONFIRM',
  modalProps: {title, message, confirmCallback, cancelCallback}

showErrorDialog = ({title,  message}) ->
  type:       ReactModal.SHOW_MODAL,
  modalType: 'ERROR',
  modalProps: {title, message}

showInfoDialog = ({title,  message}) ->
  type:       ReactModal.SHOW_MODAL,
  modalType: 'INFO',
  modalProps: {title, message}

# export
export {
  showConfirmDialog
  showErrorDialog
  showInfoDialog
}

