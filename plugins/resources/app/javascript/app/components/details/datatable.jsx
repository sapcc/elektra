//A <table> with pagination and sorting. Give the individual table rows as
//children, and specify column attributes in props.columns like this:
//
//    columns = [
//      { key: 'id', label: 'Volume ID' },
//      { key: 'size', label: 'Volume Size', sort: 'numeric' },
//      { key: 'status', label: 'Status', sort: 'text' },
//    ]
//
//To enable pagination, give the maximum number of rows as props.pageSize.
//(TODO not implemented yet)
//
//For columns that are declared as sortable, sorting happens by calling the
//`sort_key_${column_key}` method on each child, so the children need to be
//class-based components and should have member methods like this:
//
//    sort_key_size() {
//      return this.props.volume.size;
//    }
//    sort_key_status() {
//      return this.props.volume.status;
//    }
//
//Besides that, the children also need to have a `key` method that returns a
//key that's unique within the set of children in the DataTable:
//
//    key() {
//      return this.props.volume.id;
//    }
//
//Other than that, the children should just render one <tr> each with the same
//column layout as defined in props.columns of the DataTable.
//
//TODO: move this into app/javascript/lib/ in the repo root
export default class DataTable extends React.Component {
  state = {
    sortColumnIdx: null,  //index into this.props.columns
    sortDirection: null, //'asc' or 'desc'
  }

  setSortColumnIdx(columnIdx) {
    if (this.state.sortColumnIdx == columnIdx) {
      //when already sorted on this column, just flip direction
      this.setState({
        ...this.state,
        sortDirection: this.state.sortDirection == 'asc' ? 'desc' : 'asc',
      });
    } else {
      this.setState({
        ...this.state,
        sortColumnIdx: columnIdx,
        sortDirection: 'asc',
      });
    }
  }

  renderColumnHeader(column, columnIdx) {
    const isSorted = (this.state.sortColumnIdx == columnIdx);
    const isSortable = (column.sort != null);

    const extraProps = {};
    if (isSortable) {
      extraProps.className = 'sortable';
      extraProps.onClick = (e) => {
        e.stopPropagation();
        this.setSortColumnIdx(columnIdx);
      };

      extraProps.title = (isSorted && this.state.sortDirection == 'asc')
        ? 'Click to sort in descending order'
        : 'Click to sort in ascending order';
    }

    const sortIconType = column.sort == 'text' ? 'alpha' : 'amount';
    return (
      <th key={column.key} {...extraProps}>
        {column.label}
        {isSortable && ' '}
        {isSorted && <i className={`fa fa-sort-${sortIconType}-${this.state.sortDirection}`} />}
        {!isSorted && isSortable && <i className={`fa fa-sort-${sortIconType}-asc sortable-hint`} />}
      </th>
    );
  }

  render() {
    return (
      <table className='table elektraDataTable'>
        <thead>
          <tr>{this.props.columns.map((column, idx) => this.renderColumnHeader(column, idx))}</tr>
        </thead>
        <tbody>
          {this.props.children}
        </tbody>
      </table>
    );
  }

}
