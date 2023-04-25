import React from "react"
// import { createPortal } from "react-dom"

// This Components uses the bootstrap 3 jQuery approach to place the tooltip
export const Tooltip = ({
  content,
  children,
  placement = "top",
  html = false,
  delay,
}) => {
  const ref = React.useRef()
  React.useEffect(() => {
    if (!ref.current) return
    window.$(ref.current).tooltip({ html, placement, title: content, delay })
    return () => window.$(ref.current).tooltip("destroy")
  }, [])

  return React.cloneElement(children, { ref })
}

// This Components uses the bootstrap 3 jQuery approach to place the tooltip
export const Popover = ({
  trigger,
  title,
  content,
  children,
  placement = "top",
  html = false,
}) => {
  const ref = React.useRef()
  React.useEffect(() => {
    if (!ref.current) return
    window.$(ref.current).popover({ html, placement, title, content, trigger })
    return () => window.$(ref.current).popover("destroy")
  }, [])

  return React.cloneElement(children, { ref })
}

/*
// This approach uses the markup from bootstrap 3 but it uses React to
// place the Tooltip (Portal + Position calculation)
let tooltipsContainer = document.querySelector("[data-tooltips-container]")
if (!tooltipsContainer) {
  tooltipsContainer = document.createElement("div")
  tooltipsContainer.setAttribute("data-tooltips-container", "true")
  document.body.append(tooltipsContainer)
}

const TooltipContent2 = ({ content, hostRef, position }) => {
  const [show, setShow] = React.useState(false)

  React.useEffect(() => {
    if (!hostRef.current) return

    hostRef.current.onmouseover = () => setShow(true)
    hostRef.current.onmouseleave = () => setShow(false)
  }, [])

  if (!show) return null
  return createPortal(
    <div
      ref={(el) => {
        if (!el || !hostRef.current || el.classList.contains("in")) return
        const host = hostRef.current.getBoundingClientRect()
        const tooltip = el.getBoundingClientRect()
        switch (position) {
          case "top":
            el.style.left = `${host.x + host.width / 2 - tooltip.width / 2}px`
            el.style.top = `${host.y - tooltip.height}px`
            break
          case "bottom":
            el.style.left = `${host.x + host.width / 2 - tooltip.width / 2}px`
            el.style.top = `${host.y + host.height}px`
            break
          case "left":
            el.style.left = `${host.x - tooltip.width}px`
            el.style.top = `${host.y + host.height / 2 - tooltip.height / 2}px`
            break
          case "right":
            el.style.left = `${host.x + host.width}px`
            el.style.top = `${host.y + host.height / 2 - tooltip.height / 2}px`
            break
        }

        el.classList.add("in")

        console.log(el)
      }}
      className={`tooltip fade ${position}`}
      role="tooltip"
    >
      <div className="tooltip-arrow"></div>
      <div className="tooltip-inner">{content}</div>
    </div>,
    tooltipsContainer
  )
}

export const Tooltip2 = ({ children, content, position = "top" }) => {
  const ref = React.useRef()

  return (
    <>
      {React.cloneElement(children, { ref })}
      <TooltipContent2 content={content} hostRef={ref} position={position} />
    </>
  )
}
*/
