//A <table> with pagination and sorting. Give the individual table rows as
//children, and specify column attributes in props.columns like this:
//
//    //NOTE: Place this on the package level, not in render(), so that the
//    //same array gets reused across render() calls.
//    const columns = [
//      { key: 'id', label: 'Volume ID' },
//      { key: 'size', label: 'Volume Size',
//        sortStrategy: 'numeric', sortKey: props => props.volume.size || 0 },
//      { key: 'status', label: 'Status',
//        sortStrategy: 'text', sortKey: props => props.volume.status || '' },
//    ];
//
//    render() {
//      ...
//      return (
//        <DataTable columns={columns} ...>
//          {entries.map(entry => <MyRowComponent key={entry.id} data={entry} ... />)}
//        </DataTable>
//      ;
//    }
//
//To enable pagination, give the maximum number of rows as props.pageSize.
//(TODO not implemented yet)
//
//Columns can be declared as sortable by setting `sortStrategy` to either
//`numeric` or `text`. In either case, `sortKey` must be a function that
//extracts the sorting key for a given row from its props. For the `numeric`
//sorting strategy, this must return a number. For the `text` sorting strategy,
//this must return a string.
//
//Each child element should render exactly one <tr> each with the same
//column layout as defined in props.columns of the DataTable.
//
//TODO: move this into app/javascript/lib/ in the repo root

const sorters = {
  text:    (a, b) => a[1].localeCompare(b[1]),
  numeric: (a, b) => a[1] - b[1],
};

export default class DataTable extends React.Component {
  state = {
    sortColumnIdx: null,  //index into this.props.columns
    sortDirection: null,  //'asc' or 'desc'
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
    const isSortable = (column.sortStrategy != null);

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

    const sortIconType = column.sortStrategy == 'text' ? 'alpha' : 'amount';
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
    //sort rows if requested
    let rows = this.props.children;

    //if requested, sort rows using a classic Schwartzian transform
    if (this.state.sortColumnIdx != null) {
      const column = this.props.columns[this.state.sortColumnIdx];
      const sorter = sorters[column.sortStrategy];

      rows = rows
        .map(row => [ row, column.sortKey(row.props) ])
        .sort(sorter)
        .map(pair => pair[0]);
      if (this.state.sortDirection == 'desc') {
        rows.reverse();
      }
    }

    return (
      <table className='table elektraDataTable'>
        <thead>
          <tr>{this.props.columns.map((column, idx) => this.renderColumnHeader(column, idx))}</tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }

}
