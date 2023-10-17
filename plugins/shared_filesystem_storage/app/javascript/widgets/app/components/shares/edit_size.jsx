import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import React from "react"

// export default class EditShareSizeForm extends React.Component {
//   state = {
//     show: false,
//   }

//   componentDidMount() {
//     this.setState({ show: this.props.share != null })
//   }

//   UNSAFE_componentWillReceiveProps(nextProps) {
//     this.setState({ show: nextProps.share != null })
//   }

//   restoreUrl = (e) => {
//     if (!this.state.show)
//       this.props.history.replace(`/${this.props.match.params.parent}`)
//   }

//   hide = (e) => {
//     if (e) e.stopPropagation()
//     this.setState({ show: false })
//   }

//   onSubmit = (values) => {
//     return this.props.handleSubmit(values).then(() => this.hide())
//   }

//   render() {
//     // console.log(this.props.share)
//     return (
//       <Modal
//         show={this.state.show}
//         onHide={this.hide}
//         onExited={this.restoreUrl}
//         bsSize="large"
//         aria-labelledby="contained-modal-title-lg"
//       >
//         <Modal.Header closeButton>
//           <Modal.Title id="contained-modal-title-lg">
//             Extend / Shrink Share Size
//           </Modal.Title>
//         </Modal.Header>

//         <Form
//           onSubmit={this.onSubmit}
//           className="form form-horizontal"
//           validate={(values) => true}
//           initialValues={this.props.share}
//         >
//           <Modal.Body>
//             <Form.Errors />

//             <Form.ElementHorizontal label="Name" name="name">
//               <Form.Input
//                 elementType="input"
//                 type="text"
//                 name="name"
//                 disabled
//               />
//             </Form.ElementHorizontal>

//             <Form.ElementHorizontal label="ID" name="id">
//               <Form.Input elementType="input" type="text" name="id" disabled />
//             </Form.ElementHorizontal>

//             <Form.ElementHorizontal label="Size (GB)" name="size">
//               <Form.Input elementType="input" type="number" name="size" />
//             </Form.ElementHorizontal>
//           </Modal.Body>
//           <Modal.Footer>
//             <Button onClick={this.hide}>Cancel</Button>
//             <Form.SubmitButton label="Save" />
//           </Modal.Footer>
//         </Form>
//       </Modal>
//     )
//   }
// }

const EditShareSizeForm = ({
  share,
  history,
  match,
  handleSubmit,
  ...props
}) => {
  const [show, setShow] = React.useState(false)

  React.useEffect(() => {
    setShow(share != null)
  }, [setShow])

  const restoreUrl = React.useCallback(
    (e) => {
      if (show) return
      history.replace(`/${match.params.parent}`)
    },
    [show]
  )

  const hide = React.useCallback(
    (e) => {
      e?.stopPropagation()
      setShow(false)
    },
    [setShow]
  )

  const onSubmit = React.useCallback(
    (values) => {
      return handleSubmit(values).then(hide)
    },
    [hide]
  )

  // console.log(this.props.share)
  return (
    <Modal
      show={show}
      onHide={hide}
      onExited={restoreUrl}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Extend / Shrink Share Size
        </Modal.Title>
      </Modal.Header>

      <Form
        onSubmit={onSubmit}
        className="form form-horizontal"
        validate={() => true}
        initialValues={share}
      >
        <Modal.Body>
          <Form.Errors />

          <Form.ElementHorizontal label="Name" name="name">
            <Form.Input elementType="input" type="text" name="name" disabled />
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label="ID" name="id">
            <Form.Input elementType="input" type="text" name="id" disabled />
          </Form.ElementHorizontal>

          <Form.ElementHorizontal label="Size (GB)" name="size">
            <Form.Input elementType="input" type="number" name="size" />
          </Form.ElementHorizontal>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={hide}>Cancel</Button>
          <Form.SubmitButton label="Save" />
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default EditShareSizeForm
