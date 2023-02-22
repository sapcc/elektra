import { useQuery } from "@tanstack/react-query"
import { fetchCiphers } from "../widgets/app/actions/listener"

export const queryTlsCiphers = () => {
  return useQuery(["ciphers"], fetchCiphers, {
    // If set to Infinity, the data will never be considered stale
    staleTime: Infinity,
  })
}
