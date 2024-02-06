import { TransitionGroup, CSSTransition } from "react-transition-group"
import { policy } from "lib/policy"
import { SearchField } from "lib/components/search_field"
import Item from "./item"
import { AjaxPaginate } from "lib/components/ajax_paginate"
import React, { useState, useEffect, useCallback, useMemo } from "react"

const TableRowFadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={200} classNames="css-transition-fade">
    {children}
  </CSSTransition>
)

// upgrade to functional components (6.2.24)
const List = ({
  items,
  active,
  loadOsImagesOnce,
  searchOsImages,
  searchTerm,
  hasNext,
  isFetching,
  loadNext,
  handleAccept,
  handleReject,
  activeTab,
  visibilityCounts,
  activeVisibilityFilter,
  setActiveVisibilityFilter,
  ...otherProps
}) => {
  const availableVisibilityFilters = useMemo(() => {
    if (!visibilityCounts) return []
    return Object.keys(visibilityCounts)
  }, [visibilityCounts])

  useEffect(() => {
    if (active) loadOsImagesOnce()
  }, [active, activeVisibilityFilter, loadOsImagesOnce])

  const filteredItems = useMemo(() => {
    // filter items dependent on the active filter
    let result = items.filter((i) => activeVisibilityFilter == i.visibility)

    if (!searchTerm) return result

    // search term is given -> filter items dependent on the search term
    const regex = new RegExp(searchTerm.trim(), "i")
    return result.filter(
      (i) => `${i.name} ${i.id} ${i.format} ${i.status}`.search(regex) >= 0
    )
  }, [items, searchTerm, activeVisibilityFilter])

  return (
    <div>
      <div className="toolbar">
        <SearchField
          onChange={(term) => searchOsImages(term)}
          placeholder="name, ID, format or status"
          text="Searches by name, ID, format or status in visible images list only.
                Entering a search term will automatically start loading the next pages
                and filter the loaded items using the search term. Emptying the search
                input field will show all currently loaded items."
        />
        {availableVisibilityFilters?.length > 1 && ( // show filter checkboxes
          <>
            <span className="toolbar-input-divider"></span>
            <label>Show:</label>
            {availableVisibilityFilters.map((name, index) => (
              <label className="radio-inline" key={index}>
                <input
                  type="radio"
                  onChange={() => setActiveVisibilityFilter(name)}
                  checked={activeVisibilityFilter === name}
                />
                {name}
              </label>
            ))}
          </>
        )}
        <div style={{ display: "flex", flexGrow: 1, justifyContent: "end" }}>
          {isFetching ? (
            <div>
              <span className="spinner" />
            </div>
          ) : (
            visibilityCounts[activeVisibilityFilter] || 0
          )}{" "}
          Images
        </div>
      </div>
      {!policy.isAllowed("image:image_list") ? (
        <span>You are not allowed to see this page</span>
      ) : (
        <div>
          <table className="table shares">
            <thead>
              <tr>
                <th></th>
                <th>Name</th>
                <th>Format</th>
                <th>Size</th>
                <th>Created</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <TransitionGroup component="tbody">
              {filteredItems.length > 0 ? (
                filteredItems.map(
                  (image, index) =>
                    !image.isHidden && (
                      <TableRowFadeTransition key={index}>
                        <Item
                          {...otherProps}
                          image={image}
                          handleAccept={handleAccept}
                          handleReject={handleReject}
                          activeTab={activeTab}
                        />
                      </TableRowFadeTransition>
                    )
                )
              ) : (
                <TableRowFadeTransition>
                  <tr>
                    <td colSpan="7">
                      {isFetching ? (
                        <span className="spinner" />
                      ) : (
                        "No images found."
                      )}
                    </td>
                  </tr>
                </TableRowFadeTransition>
              )}
            </TransitionGroup>
          </table>

          <AjaxPaginate
            hasNext={hasNext}
            isFetching={isFetching}
            onLoadNext={loadNext}
          />
        </div>
      )}
    </div>
  )
}

export default List

// export default class List extends React.Component {
//   state = {
//     visibilityFilters: ["private", "public", "shared"],
//     activeFilter: null,
//   }

//   UNSAFE_componentWillReceiveProps(nextProps) {
//     if (nextProps.items && nextProps.items.length > 0) {
//       // build available filters array
//       let availableFilters = this.state.visibilityFilters.slice()
//       for (let i of nextProps.items) {
//         if (availableFilters.indexOf(i.visibility) < 0)
//           availableFilters.push(i.visibility)
//       }
//       availableFilters.sort()
//       let index = availableFilters.indexOf("public")
//       if (index < 0) index = 0

//       let activeFilter = this.state.activeFilter || availableFilters[index]
//       // set available filters and set active filter to the first
//       this.setState({
//         visibilityFilters: availableFilters,
//         activeFilter: activeFilter,
//       })
//     }
//     this.loadDependencies(nextProps)
//   }

//   componentDidMount() {
//     // load dependencies unless already loaded
//     this.loadDependencies(this.props)
//   }

//   loadDependencies(props) {
//     if (!props.active) return
//     props.loadOsImagesOnce()
//   }

//   changeActiveFilter = (name) => {
//     // set active filter in state to the name
//     this.setState({ activeFilter: name })
//   }

//   filterItems = () => {
//     // filter items dependent on the active filter
//     let items = this.props.items.filter(
//       (i) => this.state.activeFilter == i.visibility
//     )

//     if (!this.props.searchTerm) return items

//     // search term is given -> filter items dependent on the search term
//     const regex = new RegExp(this.props.searchTerm.trim(), "i")
//     return items.filter(
//       (i) => `${i.name} ${i.id} ${i.format} ${i.status}`.search(regex) >= 0
//     )
//   }

//   toolbar = () => {
//     // return null if no items available
//     if (this.props.items.length <= 0) return null

//     return (
//       <div className="toolbar">
//         <SearchField
//           onChange={(term) => this.props.searchOsImages(term)}
//           placeholder="name, ID, format or status"
//           text="Searches by name, ID, format or status in visible images list only.
//                 Entering a search term will automatically start loading the next pages
//                 and filter the loaded items using the search term. Emptying the search
//                 input field will show all currently loaded items."
//         />
//         {this.state.visibilityFilters.length > 1 && ( // show filter checkboxes
//           <>
//             <span className="toolbar-input-divider"></span>
//             <label>Show:</label>
//             {this.state.visibilityFilters.map((name, index) => (
//               <label className="radio-inline" key={index}>
//                 <input
//                   type="radio"
//                   onChange={() => this.changeActiveFilter(name)}
//                   checked={this.state.activeFilter == name}
//                 />
//                 {name}
//               </label>
//             ))}
//           </>
//         )}
//       </div>
//     )
//   }

//   renderTable = () => {
//     let items = this.filterItems()

//     return (
//       <div>
//         <table className="table shares">
//           <thead>
//             <tr>
//               <th></th>
//               <th>Name</th>
//               <th>Format</th>
//               <th>Size</th>
//               <th>Created</th>
//               <th>Status</th>
//               <th></th>
//             </tr>
//           </thead>
//           <TransitionGroup component="tbody">
//             {items && items.length > 0 ? (
//               items.map(
//                 (image, index) =>
//                   !image.isHidden && (
//                     <TableRowFadeTransition key={index}>
//                       <Item
//                         {...this.props}
//                         image={image}
//                         handleAccept={this.props.handleAccept}
//                         handleReject={this.props.handleReject}
//                         activeTab={this.props.activeTab}
//                       />
//                     </TableRowFadeTransition>
//                   )
//               )
//             ) : (
//               <TableRowFadeTransition>
//                 <tr>
//                   <td colSpan="7">
//                     {this.props.isFetching ? (
//                       <span className="spinner" />
//                     ) : (
//                       "No images found."
//                     )}
//                   </td>
//                 </tr>
//               </TableRowFadeTransition>
//             )}
//           </TransitionGroup>
//         </table>

//         <AjaxPaginate
//           hasNext={this.props.hasNext}
//           isFetching={this.props.isFetching}
//           onLoadNext={this.props.loadNext}
//         />
//       </div>
//     )
//   }

//   render() {
//     return (
//       <div>
//         {this.toolbar()}
//         {!policy.isAllowed("image:image_list") ? (
//           <span>You are not allowed to see this page</span>
//         ) : (
//           this.renderTable()
//         )}
//       </div>
//     )
//   }
// }
