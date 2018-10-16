import { HashRouter, Link, withRouter } from 'react-router-dom'

const Title = withRouter((props) => {
  return (
    <span>
      <i className="fa fa-angle-right"/>&nbsp;
      <Link to='/'>Security Groups</Link>
    </span>
  )
})

export default () => <HashRouter><Title/></HashRouter>
