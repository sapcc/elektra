import "./helpers.coffee"

import { connect } from "react-redux"

const ReactModal = {
  SHOW_MODAL: "SHOW_MODAL",
  HIDE_MODAL: "HIDE_MODAL",
  HIDE_ALL: "HIDE_ALL",
}

const addModalUrlFragment = ({ modalType, modalProps }) => {
  let overlayParams = "&modal=#{modalType}"
  overlayParams +=
    "&" +
    Object.keys(modalProps)
      .map((k) => `${k}=${modalProps[k]}`)
      .join("&")
  if (window.location.hash.indexOf("&modal") >= 0)
    window.location.hash.replace(/&modal.*/, overlayParams)
  else window.location.hash += overlayParams
}

const removeModalUrlFragment = ({ modalType, modalProps }) => {
  window.location.hash = window.location.hash.replace(/&modal.*/g, "")
}

const Modal =
  (title, WrappedComponent, options) =>
  ({ dispatch, modalType, modalProps, ...props }) => {
    const elementRef = React.useRef()

    const close = React.useCallback(
      (e) => {
        if (e) e.preventDefault()
        if (!elementRef.current) return
        $(elementRef.current).modal("hide")
      },
      [elementRef.current]
    )

    const handleClose = React.useCallback(() => {
      if (dispatch) dispatch({ type: ReactModal.HIDE_MODAL, modalType })
    }, [dispatch, modalType])

    React.useEffect(() => {
      if (!elementRef.current) return
      $(elementRef.current).modal("show")
      $(elementRef.current).on("hidden.bs.modal", handleClose)
    }, [elementRef.current, handleClose])

    options = ReactHelpers.mergeObjects({ closeButton: true }, options)
    modalProps = modalProps || {}
    const childProps = { modalType, dispatch, close, modalProps, ...props }

    return (
      <div
        className="modal fade"
        data-backdrop={options.static == true ? "static" : true}
        tabIndex="-1"
        ref={elementRef}
        role="dialog"
        aria-labelledby="myModalLabel"
      >
        <div
          className={`modal-dialog ${options.large ? "modal-lg" : ""} ${
            options.xlarge ? "modal-xl" : ""
          }`}
          role="document"
        >
          <div className="modal-content">
            <div className="modal-header">
              {options.closeButton && (
                <button
                  type="button"
                  className="close"
                  data-dismiss="modal"
                  aria-label="Close"
                >
                  <span aria-hidden="true">x</span>
                </button>
              )}
              <h4 className="modal-title">{title}</h4>
            </div>
            <WrappedComponent {...childProps} />
          </div>
        </div>
      </div>
    )
  }

ReactModal.Wrapper = (title, WrappedComponent, options = {}) =>
  connect((state) => state)(Modal(title, WrappedComponent, options))

ReactModal.Reducer = (state = [], action) => {
  switch (action.type) {
    case ReactModal.SHOW_MODAL: {
      let contains = false
      for (let m of state) {
        if (m.modalType === action.modalType) {
          contains = true
          break
        }
      }

      if (contains) return state
      let newState = state.slice()
      newState.push({
        modalType: action.modalType,
        modalProps: action.modalProps,
      })

      //addModalUrlFragment(action)
      return newState
    }
    case ReactModal.HIDE_MODAL: {
      const index = state.findIndex(
        (entry) => entry.modalType === action.modalType
      )
      if (index < 0) return state
      let newState = state.slice()
      newState.splice(index, 1)

      //removeModalUrlFragment(action)
      return newState
    }
    case ReactModal.HIDE_ALL:
      return []
    default:
      return state
  }
}

ReactModal.Container = (reducerName, componentsMap) => {
  let ModalRoot = ({ modals }) => {
    if (!modals || modals.length === 0) return null

    return (
      <div>
        {modals.map(
          (modal) =>
            modal.modalType &&
            componentsMap[modal.modalType] &&
            React.createElement(componentsMap[modal.modalType], {
              key: modal.modalType,
              modalType: modal.modalType,
              modalProps: modal.modalProps,
            })
        )}
      </div>
    )
  }

  return connect((state) => ({ modals: state[reducerName] }))(ModalRoot)
}

window.ReactModal = ReactModal
