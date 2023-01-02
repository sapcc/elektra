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

export const querySecretsForSelect = (options, ready) => {
  return useQuery(["secretsSelect", options], fetchSecretsForSelect, {
    // The query will not execute until the bearerToken exists
    enabled: !!ready,
  })
}
