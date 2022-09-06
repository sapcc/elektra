// import React from "react"
// import { Modal, Button } from "react-bootstrap"
// import { Form } from "lib/elektra-form"
// import { useHistory } from "react-router-dom"
// import { useDispatch } from "../../stateProvider"

// const apiClient = {}

// const NewContainer = () => {
//   const history = useHistory()
//   const [show, setShow] = React.useState(true)
//   const dispatch = useDispatch()

//   React.useEffect(() => {
//     console.log("mount container new")
//     return () => console.log("unmount container new")
//   }, [])
//   const validate = React.useCallback((values) => !!values.name, [])

//   const close = React.useCallback((e) => {
//     setShow(false)
//   }, [])

//   const back = React.useCallback((e) => {
//     history.replace("/containers")
//   }, [])

//   const submit = React.useCallback(
//     (values) =>
//       apiClient
//         .osApi("object-store")
//         .post("", { container: values })
//         .then(() => apiClient.get("containers"))
//         // reload containers
//         .then((items) =>
//           Promise.resolve(dispatch({ type: "RECEIVE_CONTAINERS", items }))
//         )
//         // close modal window
//         .then(close)
//         .catch((error) => {
//           throw { errors: error.message }
//         }),
//     [close, dispatch]
//   )

//   return (
//     <Modal
//       show={show}
//       onHide={close}
//       onExit={back}
//       bsSize="large"
//       aria-labelledby="contained-modal-title-lg"
//     >
//       <Modal.Header closeButton>
//         <Modal.Title id="contained-modal-title-lg">New Entry</Modal.Title>
//       </Modal.Header>

//       <Form className="form" validate={validate} onSubmit={submit}>
//         <Modal.Body>
//           <Form.Errors />

//           <div className="row">
//             <div className="col-md-6">
//               <Form.Element label="Container name" name="name" inline required>
//                 <Form.Input elementType="input" type="text" name="name" />
//               </Form.Element>
//             </div>
//             <div className="col-md-6">
//               <div className="bs-callout bs-callout-info">
//                 <p>
//                   Inside a project, objects are stored in containers. Containers
//                   are where you define access permissions and quotas.
//                 </p>
//               </div>
//             </div>
//           </div>
//         </Modal.Body>
//         <Modal.Footer>
//           <Button onClick={close}>Cancel</Button>
//           <Form.SubmitButton label="Save" />
//         </Modal.Footer>
//       </Form>
//     </Modal>
//   )
// }

// export default NewContainer

import React from "react"
import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory } from "react-router-dom"

const NewContainer = () => {
  const history = useHistory()
  const [show, setShow] = React.useState(true)

  React.useEffect(() => {
    console.log("mount container new")
    return () => console.log("unmount container new")
  }, [])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback((e) => {
    history.replace("/containers")
  }, [])

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">New Entry</Modal.Title>
      </Modal.Header>

      <Modal.Body>TEST</Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>
        <Form.SubmitButton label="Save" />
      </Modal.Footer>
    </Modal>
  )
}

export default NewContainer
