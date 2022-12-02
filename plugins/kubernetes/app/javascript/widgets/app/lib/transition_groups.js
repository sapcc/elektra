/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS208: Avoid top-level this
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react"
const ReactCSSTransitionGroup = React.createFactory(
  React.addons.CSSTransitionGroup
)

this.ReactTransitionGroups = {}

const Fade = ({ children }) =>
  ReactCSSTransitionGroup(
    {
      transitionName: "css-transition-fade",
      transitionEnterTimeout: 500,
      transitionLeaveTimeout: 300,
    },
    children
  )

this.ReactTransitionGroups.Fade = React.createFactory(Fade)
