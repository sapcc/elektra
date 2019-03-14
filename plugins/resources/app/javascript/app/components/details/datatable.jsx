//A <table> with pagination and sorting. Give the individual table rows as
//children, and specify column attributes in props.columns like this:
//
//    columns = [
//      { key: 'id', label: 'Volume ID' },
//      { key: 'size', label: 'Volume Size', sortable: true },
//      { key: 'status', label: 'Status', sortable: true },
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

  render() {
    return (
      <table className='table'>
        <thead>
          <tr>
            {this.props.columns.map(column =>
              <th key={column.key}>
                {column.label}
              </th>
            )}
          </tr>
        </thead>
        <tbody>
          {this.props.children}
        </tbody>
      </table>
    );
  }

}
