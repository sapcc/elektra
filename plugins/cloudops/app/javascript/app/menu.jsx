/* eslint no-console:0 */
import { Link } from 'react-router-dom'

// render all components inside a hash router
export default (props) =>
  <div className="flex-header-sticky">
    <div className="mega-nav-responsive">
      <div className="container">
        <div className="mega-nav-items">
          <div className="mega-nav-block">
            <h5>
              <i className="fa fa-fw fa-search"></i>
              Finding All the Things
            </h5>
            <ul>
              <li>
                <Link to='/search'>Universal Search</Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="mega-nav-utils">
          <div className="has-feedback has-feedback-searchable u-flex-pos-right">
            <input type="text" className="form-control" value="" placeholder="Object ID, name or project ID"/>
            <span className="form-control-feedback">
              <i className="fa fa-search"></i>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
