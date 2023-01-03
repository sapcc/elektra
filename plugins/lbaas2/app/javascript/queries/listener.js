import { useQuery } from "react-query"
import {
  fetchCiphers,
  fetchSecretsForSelect,
} from "../widgets/app/actions/listener"

export const queryTlsCiphers = () => {
  return useQuery(["ciphers"], fetchCiphers, {
    // If set to Infinity, the data will never be considered stale
    staleTime: Infinity,
  })
}

const fetchSecretsForSelectAction = ({ queryKey }) => {
  const [_key, fetchParams] = queryKey
  return fetchSecretsForSelect(fetchParams)
}

export const querySecretsForSelect = (options) => {
  return useQuery(["secretsSelect", options], fetchSecretsForSelectAction, {})
}
