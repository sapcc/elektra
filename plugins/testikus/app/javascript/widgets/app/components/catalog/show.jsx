import React from "react"
import { CodeBlock, Message, Spinner, SearchInput } from "juno-ui-components"
import apiClient from "../../apiClient"

const initialState = {
  searchTerm: null,
  catalog: [],
  isFetching: false,
  error: null,
  show: false,
}

function reducer(state, action) {
  switch (action.type) {
    case "search":
      return { ...state, searchTerm: action.value }
    case "show":
      return { ...state, show: action.value }
    case "request":
      return { ...state, isFetching: true, error: null }
    case "receive":
      return { ...state, isFetching: false, catalog: action.catalog }
    case "error":
      return { ...state, isFetching: false, error: action.error }
    default:
      throw new Error()
  }
}
const Catalog = () => {
  const [state, dispatch] = React.useReducer(reducer, initialState)

  React.useEffect(() => {
    dispatch({ type: "receive" })
    apiClient
      .osApi("identity")
      .get("auth/catalog")
      .then((response) => response.data)
      .then((data) => dispatch({ type: "receive", catalog: data.catalog }))
      .catch((e) => dispatch({ type: "error", error: e.message }))
  }, [dispatch])

  const services = React.useMemo(() => {
    if (!state.searchTerm || state.searchTerm === "" || !state.catalog)
      return state.catalog

    return state.catalog.filter(
      (service) =>
        service.name.indexOf(state.searchTerm) >= 0 ||
        service.type.indexOf(state.searchTerm) >= 0
    )
  }, [state.catalog, state.searchTerm])

  return (
    <CodeBlock>
      {state.error && (
        <Message
          onDismiss={function noRefCheck() {}}
          text={state.error}
          variant="error"
        />
      )}
      {state.isFetching ? (
        <Spinner variant="primary" />
      ) : services ? (
        <>
          <SearchInput
            value={state.searchTerm || ""}
            onChange={(e) =>
              dispatch({ type: "search", value: e.target.value })
            }
            onClear={() => dispatch({ type: "search", value: null })}
          />
          <br />
          {JSON.stringify(services, null, 2)}
        </>
      ) : (
        "No catalog available"
      )}
    </CodeBlock>
  )
}

export default Catalog
