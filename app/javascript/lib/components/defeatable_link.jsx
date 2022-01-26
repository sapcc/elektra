import { Link } from "react-router-dom"

export const DefeatableLink = ({
  to,
  className,
  disabled,
  children,
  ...otherProps
}) => (
  <Link
    to={to}
    className={className || "btn btn-primary"}
    disabled={disabled}
    onClick={(e) => {
      if (disabled) e.preventDefault()
    }}
  >
    {children}
  </Link>
)
