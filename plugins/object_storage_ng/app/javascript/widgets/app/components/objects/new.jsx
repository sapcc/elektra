import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory, useParams, useRouteMatch } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"

const NewObject = () => {
  let { url } = useRouteMatch()
  const history = useHistory()
  let { name, objectPath } = useParams()
  const { value: currentPath } = useUrlParamEncoder(objectPath)
  const [show, setShow] = React.useState(true)

  const validate = React.useCallback((values) => !!values.name, [])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback(
    (e) => {
      history.replace(`/containers/${name}/objects/${objectPath}`)
    },
    [objectPath]
  )

  const submit = React.useCallback(
    (values) => null,

    // apiClient
    //   .post("containers", { container: values })
    //   .then(() => apiClient.get("containers"))
    //   // reload containers
    //   .then((items) =>
    //     Promise.resolve(dispatch({ type: "RECEIVE_CONTAINERS", items }))
    //   )
    //   // close modal window
    //   .then(close)
    //   .catch((error) => {
    //     throw { errors: error.message }
    //   }),
    [(close, dispatch)]
  )

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="large"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Create folder below: /{currentPath}
        </Modal.Title>
      </Modal.Header>

      <Form className="form" validate={validate} onSubmit={submit}>
        <Modal.Body>
          <Form.Errors />

          <Form.Element label="Folder name" name="name" inline required>
            <Form.Input elementType="input" type="text" name="name" />
          </Form.Element>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={close}>Cancel</Button>
          <Form.SubmitButton label="Create folder" />
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default NewObject
