const Item = ({ item, onDelete, canDelete, cachedProject }) => {
  const [confirm, setConfirm] = React.useState(false)
  let timer

  const getConfirmation = React.useCallback(() => {
    if (timer) clearTimeout(timer)
    setConfirm(true)
    timer = setTimeout(() => setConfirm(false), 5000)
  }, [timer])

  const remove = React.useCallback(() => {
    setConfirm(false)
    onDelete(item.id)
  }, [timer, item])

  return (
    <tr>
      <td>
        {(item.action || "").replace(/_/g, " ")}
        <br />
        <span className="info-text">ID: {item.id}</span>
      </td>
      <td>
        {cachedProject ? (
          <React.Fragment>
            {cachedProject.name}
            <br />
            <span className="info-text">ID: {item.target_tenant}</span>
          </React.Fragment>
        ) : (
          item.target_tenant
        )}
      </td>
      <td>
        {canDelete && (
          <button
            className={`btn btn-${confirm ? "danger" : "default"} btn-sm ${
              item.isDeleting ? "loading" : ""
            }`}
            disabled={item.isDeleting}
            onClick={() => (confirm ? remove() : getConfirmation())}
          >
            {confirm && "Confirm"}
            <i className="fa fa-trash fa-fw" />
          </button>
        )}
      </td>
    </tr>
  )
}

export default Item
