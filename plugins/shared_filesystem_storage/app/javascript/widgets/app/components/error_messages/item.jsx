import { policy } from "lib/policy"
import { PrettyDate } from "lib/components/pretty_date"

const Row = ({ label, value, children }) => {
  return (
    <tr>
      <th style={{ width: "30%" }}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
}

export default class ErrorMessageItem extends React.Component {
  state = { showDetails: false }

  toggleDetails = () => this.setState({ showDetails: !this.state.showDetails })

  detailsView = () => (
    <table className="table no-borders">
      <tbody>
        {[
          "project_id",
          "id",
          "resource_type",
          "resource_id",
          "detail_id",
          "action_id",
          "request_id",
          "created_at",
          "expires_at",
        ].map((key, index) => (
          <tr key={index}>
            <th>{key}</th>
            <td>{this.props.errorMessage[key]}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )

  render() {
    const { errorMessage } = this.props
    return (
      <React.Fragment>
        <tr>
          <td>
            <a
              onClick={(e) => {
                e.preventDefault()
                this.toggleDetails()
              }}
            >
              {this.state.showDetails ? (
                <i className="fa fa-fw fa-caret-down" />
              ) : (
                <i className="fa fa-fw fa-caret-right" />
              )}
            </a>
            {errorMessage.message_level}
          </td>
          <td>{errorMessage.user_message}</td>
          <td>
            <PrettyDate date={errorMessage.created_at} />
          </td>
        </tr>
        {this.state.showDetails && (
          <tr className="details">
            <td colSpan="3">{this.detailsView()}</td>
          </tr>
        )}
      </React.Fragment>
    )
  }
}
