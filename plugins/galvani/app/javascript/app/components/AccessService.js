import React from "react"
import Tag from "./Tag"
import styled from "styled-components"

const HorizontalDivider = styled.hr`
  display: block;
  height: 1px;
  border: 0;
  margin: 0;
  margin-top: 1rem;
  margin-bottom: 1rem;
  padding: 0;
  border-top: 1px solid #bbbbbb;
`

const TagsContainer = styled.div`
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
`

const AccessService = ({ serviceName, description, items }) => {
  return (
    <>
      <tr>
        <td>
          <b>{serviceName}</b>
          <div className="info-text">
            <small>{description}</small>
          </div>
        </td>
        <td>
          <TagsContainer>
            {items && items.map((tag, i) => <Tag key={i} text={tag} />)}
          </TagsContainer>
        </td>
      </tr>
    </>
  )
}

export default AccessService
