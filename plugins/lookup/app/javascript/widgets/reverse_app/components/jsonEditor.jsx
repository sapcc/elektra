import "lib/jsoneditor"

class JsonEditor extends React.Component {
  componentDidMount() {
    init_json_editor()
  }

  render() {
    return (
      <div className="objectinfo_json_editor">
        <b>{this.props.title}</b>
        <div
          id="jsoneditor"
          data-mode="view"
          data-content={JSON.stringify(this.props.details, null, 2)}
        />
      </div>
    )
  }
}

export default JsonEditor
