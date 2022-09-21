import React from "react"
import PropTypes from "prop-types"
import { Modal, Button, Alert } from "react-bootstrap"
import { useHistory, useParams } from "react-router-dom"
import useUrlParamEncoder from "../../hooks/useUrlParamEncoder"
import useActions from "../../hooks/useActions"
import { Unit } from "lib/unit"
import CustomMetaTags from "../shared/CustomMetatags"

const unit = new Unit("B")

const dateToString = (date) => {
  const leadingZero = (value) => `${value < 10 ? "0" + value : value}`
  let month = leadingZero(date.getMonth() + 1)
  let day = leadingZero(date.getDate())
  let hours = leadingZero(date.getHours())
  let minutes = leadingZero(date.getMinutes())
  let seconds = leadingZero(date.getSeconds())

  return `${date.getFullYear()}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

const stringToDate = (string) => {
  const dateTime = string.split(" ")
  const dateParts = dateTime[0].split("-")
  const timeParts = dateTime[1].split(":")
  return new Date(
    dateParts[0],
    dateParts[1],
    dateParts[2],
    timeParts[0],
    timeParts[1],
    timeParts[2]
  )
}

const ShowObject = ({ objectStoreEndpoint }) => {
  const history = useHistory()
  let { name: containerName, objectPath, object } = useParams()
  const { loadContainerMetadata, loadObjectMetadata } = useActions()
  const [containerMetadata, setContainerMetadata] = React.useState()
  const { value: currentPath } = useUrlParamEncoder(objectPath)

  const [show, setShow] = React.useState(true)
  const [error, setError] = React.useState()
  const [processing, setProcessing] = React.useState(false)
  const [metadata, setMetadata] = React.useState({})
  const [customTags, setCustomTags] = React.useState([])

  React.useEffect(() => {
    loadContainerMetadata(containerName).then((metadata) => {
      setContainerMetadata(metadata)
    })
  }, [containerName, setContainerMetadata])

  const publicUrl = React.useMemo(() => {
    if (
      !containerMetadata ||
      !/[.]r:/.test(containerMetadata["x-container-read"])
    )
      return null

    return `${objectStoreEndpoint}/${encodeURIComponent(
      containerName
    )}/${encodeURIComponent(object)}`
  }, [containerMetadata, containerName, object])

  React.useEffect(() => {
    setProcessing(true)
    setError(null)
    loadObjectMetadata(containerName, object)
      .then((metadata) => {
        setMetadata(metadata)
        const customTags = []
        for (let key in metadata) {
          const match = key.match(/^x-object-meta-(.+)$/)
          if (match) {
            customTags.push({ key: match[1], value: metadata[key] })
          }
        }
        setCustomTags(customTags)
      })
      .catch((error) => setError(error.message))
      .finally(() => setProcessing(false))
  }, [containerName, object, loadObjectMetadata])

  const close = React.useCallback(() => {
    setError(null)
    setProcessing(false)
    setMetadata({})
    setShow(false)
  }, [])

  const back = React.useCallback(() => {
    let path = `/containers/${containerName}/objects`
    if (objectPath && objectPath !== "") path += `/${objectPath}`
    history.replace(path)
  }, [containerName, objectPath])

  const submit = React.useCallback(() => {}, [
    close,
    containerName,
    currentPath,
  ])

  const createdAt = React.useMemo(() => {
    let timestamp = metadata["x-timestamp"]
    if (!timestamp) return ""
    timestamp = parseInt(timestamp.split(".")[0]) * 1000
    return dateToString(new Date(timestamp))
  }, [metadata])

  const lastModifiedAt = React.useMemo(() => {
    let dateString = metadata["x-last-modified"]
    if (!dateString) return ""

    try {
      return dateToString(new Date(dateString))
    } catch (e) {
      return ""
    }
  }, [metadata])

  const expiresAtPlaceholder = React.useMemo(() => {
    const date = new Date()
    date.setMonth(date.getMonth() + 1)

    return `Enter a timestamp like "${dateToString(
      date
    )}" to schedule automatic deletion`
  }, [])

  console.log("===containerMetadata", containerMetadata)
  console.log("===metadata", metadata)

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="large"
      dialogClassName="modal-xl"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Properties of {object}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        {error && (
          <Alert bsStyle="danger">
            <strong>An error has occurred</strong>
            <p>{error}</p>
          </Alert>
        )}
        {processing ? (
          <>
            <span className="spinner" /> Loading...
          </>
        ) : (
          <>
            <form className="form-horizontal">
              <div className="form-group">
                <label className="col-sm-2 control-label">Content type</label>
                <div className="col-sm-10">
                  <p className="form-control-static">
                    {metadata["x-content-type"] ||
                      metadata["content-type"] ||
                      ""}
                  </p>
                </div>
              </div>

              <div className="form-group">
                <label className="col-sm-2 control-label">MD5 checksum</label>
                <div className="col-sm-10">
                  <p className="form-control-static">
                    {metadata["x-etag"] || metadata["etag"] || ""}
                  </p>
                </div>
              </div>

              <div className="form-group">
                <label className="col-sm-2 control-label">Size</label>
                <div className="col-sm-10">
                  <p className="form-control-static">
                    {unit.format(
                      metadata["x-content-length"] ||
                        metadata["content-length"] ||
                        0
                    )}
                  </p>
                </div>
              </div>

              {publicUrl && (
                <div className="form-group string ">
                  <label className="control-label col-sm-2 string">
                    URL for public access
                  </label>
                  <div className="col-sm-10" style={{ display: "flex" }}>
                    <p className="form-control-static">{publicUrl}</p>
                    <a
                      className="btn"
                      target="_blank"
                      href={publicUrl}
                      rel="noreferrer"
                    >
                      <i className="fa fa-external-link" />
                    </a>
                  </div>
                </div>
              )}

              <div className="form-group">
                <label className="control-label col-sm-2 string">
                  Metadata
                </label>
                <div className="col-sm-10">
                  <CustomMetaTags
                    values={customTags} //{values.customMetadataTags}
                    onChange={
                      (values) => setContainerMetadata(values) //onChange("customMetadataTags", newValues)
                    }
                  />
                </div>
              </div>
            </form>

            {/* 
            <div className="row">
              <div className="col-md-4">
                <div className="form-group string">
                  <label className="control-label string">Content type</label>
                  <p className="form-control-static">
                    {metadata["x-content-type"] ||
                      metadata["content-type"] ||
                      ""}
                  </p>
                </div>
              </div>
              <div className="col-md-4">
                <div className="form-group string readonly">
                  <label className="control-label string">Size</label>

                  <p className="form-control-static">
                    {unit.format(
                      metadata["x-content-length"] ||
                        metadata["content-length"] ||
                        0
                    )}
                  </p>
                </div>
              </div>
              <div className="col-md-4">
                <div className="form-group string readonly">
                  <label className="control-label string">MD5 checksum</label>
                  <p className="form-control-static">
                    {metadata["x-etag"] || metadata["etag"] || ""}
                  </p>
                </div>
              </div>
            </div> */}
            {/* {publicUrl && (
              <div className="form-group string ">
                <label className="control-label string">
                  URL for public access (
                  <a target="_blank" href={publicUrl} rel="noreferrer">
                    Open in new tab
                  </a>
                  )
                </label>
                <p className="form-control-static">{publicUrl}</p>
              </div>
            )}
            <div className="row">
              <div className="col-md-6">
                <div className="form-group string">
                  <label className="control-label string">
                    Expires at (UTC)
                  </label>
                  <input
                    className="form-control string"
                    value=""
                    placeholder={expiresAtPlaceholder}
                    type="text"
                  />
                </div>
              </div>

              <div className="col-md-3">
                <div className="form-group string">
                  <label className="control-label string">Uploaded (UTC)</label>
                  <p className="form-control-static">{createdAt}</p>
                </div>
              </div>
              <div className="col-md-3">
                <div className="form-group string">
                  <label className="control-label string">
                    Last modified (UTC)
                  </label>
                  <p className="form-control-static">{lastModifiedAt}</p>
                </div>
              </div>
            </div> */}

            {/* <div className="form-group string">
              <label className="control-label string">Expires at (UTC)</label>
              <input
                className="form-control string"
                value=""
                placeholder={expiresAtPlaceholder}
                type="text"
              />
            </div> */}
            {/* <div className="form-group">
              <label>Metadata</label>
              <CustomMetaTags
                values={[]} //{values.customMetadataTags}
                onChange={
                  (newValues) => null //onChange("customMetadataTags", newValues)
                }
              />
            </div> */}
          </>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={close}>Cancel</Button>
        <Button
          bsStyle="primary"
          onClick={submit}
          disabled={!containerName || !object || processing}
        >
          {processing ? "Updating..." : "Update object"}
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default ShowObject
