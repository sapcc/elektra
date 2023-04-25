import Parent from "./parent"
import React from "react"
class Parents extends React.Component {
  renderParent = (parentsList) => {
    if (parentsList.length > 0) {
      // eslint-disable-next-line no-global-assign
      parent = parentsList[0]
      parentsList.shift()
      return (
        <ul className="fa-ul">
          <li>
            <i className="fa fa-li fa-arrow-right text-primary" />
            <Parent key={parent.id} id={parent.id} name={parent.name} />
          </li>
          {parentsList.length > 0 && <li>{this.renderParent(parentsList)}</li>}
        </ul>
      )
    }
    return null
  }

  renderParentRoot = (parentsList) => {
    if (parentsList.length > 0) {
      // eslint-disable-next-line no-global-assign
      parent = parentsList[0]
      parentsList.shift()
      return (
        <ul className="parentsList rootParent">
          <li>
            <Parent key={parent.id} id={parent.id} name={parent.name} />
          </li>
          {parentsList.length > 0 && <li>{this.renderParent(parentsList)}</li>}
        </ul>
      )
    }

    return null
  }

  render() {
    return <>{this.renderParentRoot([...this.props.parents])}</>
  }
}

export default Parents
