import React, { useState, useEffect } from "react"
import { Modal, Button } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import useLoadbalancer from "../../lib/hooks/useLoadbalancer"
import SelectInput from "../shared/SelectInput"
import useCommons from "../../lib/hooks/useCommons"
import { addNotice } from "lib/flashes"
import { matchPath } from "react-router-dom"
import Log from "../shared/logger"

const AttachFIP = (props) => {
  const { fetchFloatingIPs, attachFIP } = useLoadbalancer()
  const { matchParams, errorMessage, searchParamsToString } = useCommons()
  const [loadbalancerID, setLoadbalancerID] = useState(null)

  const [floatingIPs, setFloatingIPs] = useState({
    isLoading: false,
    error: null,
    items: [],
  })

  useEffect(() => {
    const params = matchParams(props)
    setLoadbalancerID(params.loadbalancerID)

    Log.debug("fetching floating IPs")
    setFloatingIPs({ ...floatingIPs, isLoading: true })
    fetchFloatingIPs()
      .then((data) => {
        setFloatingIPs({
          ...floatingIPs,
          isLoading: false,
          items: data,
          error: null,
        })
      })
      .catch((error) => {
        setFloatingIPs({
          ...floatingIPs,
          isLoading: false,
          error: errorMessage(error),
        })
      })
  }, [])

  /*
   * Modal stuff
   */
  const [show, setShow] = useState(true)

  const close = (e) => {
    if (e) e.stopPropagation()
    setShow(false)
  }

  const restoreUrl = () => {
    if (!show) {
      const isRequestFromDetails = matchPath(
        props.location.pathname,
        "/loadbalancers/:loadbalancerID/show/attach_fip"
      )

      if (isRequestFromDetails && isRequestFromDetails.isExact) {
        props.history.replace(
          `/loadbalancers/${loadbalancerID}/show?${searchParamsToString(props)}`
        )
      } else {
        props.history.replace("/loadbalancers")
      }
    }
  }

  /*
   * Form stuff
   */
  const [formErrors, setFormErrors] = useState(null)
  const [initialValues, setInitialValues] = useState({})

  const validate = ({ floating_ip }) => {
    return floating_ip && true
  }

  const onSubmit = (values) => {
    setFormErrors(null)
    // save the entered values in case of error
    setInitialValues(values)

    return attachFIP(loadbalancerID, values)
      .then((response) => {
        addNotice(
          <React.Fragment>
            Floating IP{" "}
            <b>{response.data.loadbalancer.floating_ip.floating_ip_address}</b>{" "}
            ({response.data.loadbalancer.floating_ip.id}) is being attached.
          </React.Fragment>
        )
        close()
      })
      .catch((error) => {
        setFormErrors(errorMessage(error))
      })
  }

  const onSelectfloatingIPChange = (values) => {}

  return (
    <Modal
      show={show}
      onHide={close}
      bsSize="large"
      backdrop="static"
      onExited={restoreUrl}
      aria-labelledby="contained-modal-title-lg"
      bsClass="lbaas2 modal"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Attach Floating IP
        </Modal.Title>
      </Modal.Header>

      <Form
        className="form form-horizontal"
        validate={validate}
        onSubmit={onSubmit}
        initialValues={initialValues}
        resetForm={false}
      >
        <Modal.Body>
          <p>
            Assign the floating IP to lbaas VIP so it could be accessed from
            external network.
          </p>
          <Form.Errors errors={formErrors} />
          <Form.ElementHorizontal
            label="Floating IP"
            name="floating_ip"
            required
          >
            <SelectInput
              name="floating_ip"
              isLoading={floatingIPs.isLoading}
              items={floatingIPs.items}
              onChange={onSelectfloatingIPChange}
            />
            {floatingIPs.error ? (
              <span className="text-danger">{floatingIPs.error}</span>
            ) : (
              ""
            )}
          </Form.ElementHorizontal>
        </Modal.Body>

        <Modal.Footer>
          <Button onClick={close}>Cancel</Button>
          <Form.SubmitButton label="Save" />
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default AttachFIP
