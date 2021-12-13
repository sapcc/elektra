import React from "react"
import styled from "styled-components"

const Item = styled.span`
  background-color: #292f37;
  padding: 1rem;
  color: #bbbbbb;
  border-radius: 0.4rem;
`

const Tag = ({ text }) => {
  return <Item>{text}</Item>
}

export default Tag
