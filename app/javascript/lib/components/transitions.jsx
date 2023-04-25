import React from "react"
import { CSSTransition } from "react-transition-group"

export const FadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={500} classNames="css-transition-fade">
    <>{children}</>
  </CSSTransition>
)
