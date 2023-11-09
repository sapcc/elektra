export const getContainerUuid = function (container) {
  const containerUuidMatch =
    container.container_ref.match(/^.*containers\/(.+)$/)
  return containerUuidMatch && containerUuidMatch[1]
}
