import { Modal, Button, Alert } from "react-bootstrap"
import { Form } from "lib/elektra-form"
import { useHistory, useParams, Link } from "react-router-dom"
import { useGlobalState } from "../../stateProvider"
import React from "react"
import { Unit } from "lib/unit"
const unit = new Unit("B")
import apiClient from "../../lib/apiClient"

/**
 * This Component renders custom metadata tags.
 * the name of custom tags starts with meta_
 * @param {map} props
 * @returns component
 */
const CustomMetaTags = ({ values, onChange, reservedKeys }) => {
  const [error, setError] = React.useState()

  reservedKeys = reservedKeys || []
  // example of values:
  // [ { "key": "meta_key1", "value": "value1" } ]

  // filter out empty tags (key is empty)
  // and add a new entry for further tags
  const tags = React.useMemo(() => {
    if (!values) return []
    const result = values.slice().filter((v) => v.key && v.key.length > 0)
    result.push({ key: "", value: "" })
    return result
  }, [values])

  // update custom metadata tags
  // updates requires two params:
  // 1. identifier of the entry e.g. 0
  // 2. new key or new value or both of them
  // example: update(0, { "key": "xyz"})
  // example: update(1, { "value": "valueXYZ"})
  const update = React.useCallback(
    (index, { key, value }) => {
      let errors = []
      // do not allow to overwrite existing keys
      const oldKeys = tags.map((t) => t.key)
      if (!value && key && oldKeys.includes(key))
        errors.push("the key already exists")
      // do not allow to overwrite reserved keys
      if (reservedKeys.indexOf(key) >= 0) {
        errors.push("reserved key (will be ignored)")
      }
      setError(errors.length > 0 ? errors.join(", ") : null)

      const newValues = tags.slice()
      if (key !== undefined) newValues[index].key = key
      if (value !== undefined) newValues[index].value = value

      onChange(newValues)
    },
    [tags]
  )

  return (
    <React.Fragment>
      <div className="small">Reserved keys: {reservedKeys.join(", ")}</div>
      {error && <Alert bsStyle="danger">{error}</Alert>}
      {tags.map((tag, i) => (
        <React.Fragment key={i}>
          <div className="input-group">
            <input
              type="text"
              value={tag ? tag.key : ""}
              placeholder="Key"
              onChange={(e) => {
                e.preventDefault()
                update(i, { key: e.target.value })
              }}
              className="string optional form-control"
            />
            <div className="input-group-addon">=</div>
            <input
              type="text"
              value={tag.value || ""}
              onChange={(e) => {
                e.preventDefault()
                update(i, { value: e.target.value })
              }}
              placeholder="Value"
              className="string optional form-control"
            />
          </div>
        </React.Fragment>
      ))}
    </React.Fragment>
  )
}

const FormBody = ({ containerName, otherContainers }) => {
  const { formValues: values, onChange } = React.useContext(Form.Context)

  return (
    <React.Fragment>
      <div className="row">
        <div className="col-md-6">
          <Form.Element label="Object count" name="object_count" inline>
            <Form.Input
              disabled
              elementType="input"
              type="text"
              name="object_count"
            />
          </Form.Element>
          <Form.Element label="Total size" name="total_size" inline>
            <Form.Input
              disabled
              elementType="input"
              type="text"
              name="total_size"
            />
          </Form.Element>
        </div>
        <div className="col-md-6">
          <Form.Element
            label="Object count quota"
            name="meta_quota_count"
            inline
          >
            <Form.Input
              placeholder="Leave empty to disable"
              elementType="input"
              type="number"
              name="meta_quota_count"
            />
          </Form.Element>
          <Form.Element label="Total size quota" name="meta_quota_bytes" inline>
            <Form.Input
              placeholder="Leave empty to disable"
              elementType="input"
              type="text"
              name="meta_quota_bytes"
            />
            {values.meta_quota_bytes && (
              <small className="text-info">
                {unit.format(values.meta_quota_bytes)}
              </small>
            )}
          </Form.Element>
        </div>
      </div>
      {/[.]r:/.test(values.read) && (
        <React.Fragment>
          <label className="control-label">
            URL for public access{" "}
            <a href={values.public_url} target="_blank">
              (Open in new tab)
            </a>
          </label>
          <div className="form-group">
            <input
              className="form-control"
              type="text"
              disabled
              defaultValue={values.public_url}
            />
          </div>
        </React.Fragment>
      )}
      {values.cap_staticweb && (
        <div className="form-group">
          <label>Static website serving</label>
          {values.read == ".r:*,.rlistings" ? (
            <React.Fragment>
              <div className="row">
                <div className="col-md-6">
                  <div className="checkbox">
                    <label>
                      <Form.Input
                        elementType="input"
                        type="checkbox"
                        name="meta_web_index_enabled"
                      />{" "}
                      Serve objects as{" "}
                      {values.meta_web_index.replace(".html", "")}
                      {values.meta_web_index_enabled && " when file name is:"}
                    </label>
                  </div>
                </div>
                <div className="col-md-6">
                  {values.meta_web_index_enabled && (
                    <Form.Input
                      elementType="input"
                      type="text"
                      name="meta_web_index"
                    />
                  )}
                </div>
              </div>
              <div className="row">
                <div className="col-md-12">
                  <div className="checkbox">
                    <label>
                      <Form.Input
                        elementType="input"
                        type="checkbox"
                        name="meta_web_listings"
                      />{" "}
                      Enable file listing{" "}
                      <i
                        className="fa fa-question-circle help_icon"
                        title="If there is no index file, the URL displays a list of objects in the container."
                      />
                    </label>
                  </div>
                </div>
              </div>
            </React.Fragment>
          ) : (
            <div className="bs-callout bs-callout-info">
              Before configuring static website serving, go to{" "}
              <Link to={`/containers/${containerName}/access-control`}>
                Access control
              </Link>{" "}
              and enable public read access.
            </div>
          )}
        </div>
      )}
      <div className="form-group">
        <label>Object versioning</label>

        <div className="row">
          <div className="col-md-6">
            <div className="checkbox">
              <label>
                <Form.Input
                  elementType="input"
                  type="checkbox"
                  name="versions_location_enabled"
                />{" "}
                Store old object versions{" "}
                {values.versions_location_enabled && " in container:"}
              </label>
            </div>
          </div>

          <div className="col-md-6">
            {values.versions_location_enabled && (
              <Form.Input
                elementType="select"
                className="select required form-control"
                name="versions_location"
              >
                <option></option>
                {otherContainers.map((c, i) => (
                  <option key={i} value={c.name}>
                    {c.name}
                  </option>
                ))}
              </Form.Input>
            )}
          </div>
        </div>
      </div>

      <div className="form-group">
        <label>Metadata</label>
        <CustomMetaTags
          reservedKeys={[
            "web-index",
            "web-listings",
            "quoty-count",
            "quota-bytes",
          ]}
          values={values.customMetadataTags}
          onChange={(newValues) => onChange("customMetadataTags", newValues)}
        />
      </div>
    </React.Fragment>
  )
}

const ContainerProperties = ({ objectStoreEndpoint }) => {
  const { name } = useParams()
  const history = useHistory()
  const [show, setShow] = React.useState(!!name)
  const [error, setError] = React.useState()
  const { containers, capabilities } = useGlobalState()

  const [metadata, setMetadata] = React.useState()
  const [isFetchingMetadata, setIsFetchingMetadata] = React.useState(false)

  const customMetadataTags = React.useMemo(() => {
    if (!metadata) return []
    const result = []
    const reserved = [
      "x-container-meta-web-index",
      "x-container-meta-web-listings",
      "x-container-meta-quota-count",
      "x-container-meta-quota-bytes",
    ]
    Object.keys(metadata).forEach((k) => {
      if (k.startsWith("x-container-meta-") && reserved.indexOf(k) < 0)
        result.push({
          key: k.replace("x-container-meta-", ""),
          value: metadata[k],
        })
    })
    return result
  }, [metadata])

  React.useEffect(() => {
    setIsFetchingMetadata(true)
    apiClient
      .osApi("object-store")
      .head(name)
      .then((response) => setMetadata(response.headers))
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => setIsFetchingMetadata(false))

    return () => setMetadata(null)
  }, [name])

  const otherContainers = React.useMemo(() => {
    if (containers.isFetching) return
    return containers.items.filter((i) => i.name !== name)
  }, [containers, name])

  const close = React.useCallback((e) => {
    setShow(false)
  }, [])

  const back = React.useCallback((e) => {
    history.replace("/containers")
  }, [])

  const submit = React.useCallback(
    (values) => {
      if (!metadata) return Promise.reject("Could not find container")

      let newValues = {
        "x-versions-location":
          (values.versions_location_enabled && values.versions_location) || "",
        "x-container-meta-web-index":
          values.meta_web_index_enabled && values.meta_web_index,
        "x-container-meta-web-listings": values.meta_web_listings ? "1" : "",
        "x-container-meta-quota-count": values.meta_quota_count,
        "x-container-meta-quota-bytes": values.meta_quota_bytes,
      }
      const reservedKeys = Object.keys(newValues)
      values.customMetadataTags.forEach((t) => {
        const key = `x-container-meta-${t.key}`
        if (reservedKeys.indexOf(key) < 0) newValues[key] = t.value
      })

      for (let key in metadata) {
        if (!key.startsWith("x-container-meta")) continue
        if ((metadata[key] && !newValues[key]) || !newValues[key]) {
          newValues[key.replace("x-container", "x-remove-container")] = "1"
          delete newValues[key]
        }
      }

      Object.keys(newValues).forEach((key) => {
        if (
          newValues[key] === undefined ||
          newValues[key] === "false" ||
          newValues[key] === false
        ) {
          newValues[key] = ""
        }
      })

      return (
        apiClient
          .osApi("object-store")
          .post(name, {}, { headers: newValues })
          // close modal window
          .then(close)
          .catch((error) => {
            setError(error.message)
          })
      )
    },
    [metadata, close, name]
  )

  const initialValues = React.useMemo(() => {
    if (!metadata) return {}
    return {
      public_url: `${objectStoreEndpoint}/${encodeURIComponent(name)}/`,
      versions_location: metadata["x-versions-location"],
      versions_location_enabled: !!metadata["x-versions-location"],
      cap_staticweb: capabilities.data?.staticweb && true,
      meta_web_index_enabled: !!metadata["x-container-meta-web-index"],
      meta_web_listings: !!metadata["x-container-meta-web-listings"],
      meta_web_index: metadata["x-container-meta-web-index"] || "index.html",
      total_size: unit.format(metadata["x-container-bytes-used"]),
      object_count: metadata["x-container-object-count"],
      meta_quota_count: metadata["x-container-meta-quota-count"],
      meta_quota_bytes: metadata["x-container-meta-quota-bytes"],
      read: metadata["x-container-read"],
      customMetadataTags,
    }
  }, [metadata, customMetadataTags, capabilities, name])

  return (
    <Modal
      show={show}
      onHide={close}
      onExit={back}
      bsSize="lg"
      dialogClassName="modal-xl"
      aria-labelledby="contained-modal-title-lg"
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-lg">
          Container: {name}
        </Modal.Title>
      </Modal.Header>

      {isFetchingMetadata ? (
        <Modal.Body>
          <span className="spinner" /> Loading...
        </Modal.Body>
      ) : (
        <Form
          onSubmit={submit}
          className="form"
          validate={() => true}
          initialValues={initialValues}
        >
          <Modal.Body>
            {isFetchingMetadata ? (
              <span>
                <span className="spinner" />
                Loading...
              </span>
            ) : !metadata ? (
              <span>Container not found!</span>
            ) : error ? (
              <Alert bsStyle="danger">{error}</Alert>
            ) : (
              <FormBody
                containerName={name}
                otherContainers={otherContainers}
              />
            )}
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={close}>Cancel</Button>
            {metadata && <Form.SubmitButton label="Save" />}
          </Modal.Footer>
        </Form>
      )}
    </Modal>
  )
}

export default ContainerProperties
