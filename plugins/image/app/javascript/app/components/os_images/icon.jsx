import { OverlayTrigger, Tooltip } from "react-bootstrap"

export const ImageIcon = ({ image }) => {
  const tooltip = <Tooltip id="imageIconTooltip">{image.visibility}</Tooltip>
  let iconType
  switch (image.visibility) {
    case "public":
      iconType = "fa-cloud"
      break
    case "private":
      iconType = "fa-lock"
      break
    case "community":
      iconType = "fa-users"
      break
    case "shared":
      iconType = "fa-share"
      break
  }

  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      delayShow={300}
      delayHide={150}
    >
      <i className={`text-primary fa fa-fw ${iconType}`} />
    </OverlayTrigger>
  )
}
