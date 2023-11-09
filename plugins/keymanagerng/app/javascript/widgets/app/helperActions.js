
import apiClient from "./apiClient"
export const getUsername = ({ queryKey }) => {
  const [_key, creatorId] = queryKey
  return fetchUsername(creatorId)
}

export const fetchUsername = (creatorId) => {
  return apiClient.get(`/username?user_id=${creatorId}`).then((response) => {
    return response?.data
  })
}