/* eslint no-console:0 */
import { NavLink, withRouter } from 'react-router-dom'
import { SearchField } from 'lib/components/search_field';

// render all components inside a hash router
export default (props) => {
  const search = (term) => {
    // if(term==null|| term.trim().length==0) return

    props.search({term})
    props.history.replace(`/universal-search`)
  }

  return(
    <div className="flex-header-sticky">
      <div className="mega-nav-responsive">
        <div className="container">
          <div className="mega-nav-items">
            <ul className="mega-nav-block">
              <li>
                <NavLink to='/universal-search'>Universal Search</NavLink>
              </li>
              <li>
                <NavLink to='/project-role-assignments'>Project Role Assignments</NavLink>
              </li>

            </ul>
          </div>

          <div className="mega-nav-utils">
            <ul className="mega-nav-block">
              <li>
                <a href={window.location.href.replace(/(.*)\/cloudops.*/, "$1/home")}>
                  Go to Cloudadmin
                  <i className="fa fa-share-square u-text-icon-left-margin"></i>
                </a>
              </li>
            </ul>
            <SearchField
              onChange={(term) => search(term)}
              value={props.objects.searchTerm}
              placeholder='Object ID, name or project ID'/>
          </div>
        </div>
      </div>
    </div>
  )
}
