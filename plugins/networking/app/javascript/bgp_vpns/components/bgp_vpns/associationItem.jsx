const Item = ({ routerId, cachedData, router, onDelete, isFetching }) => {
  const [isDeleting, setIsDeleting] = React.useState(false)

  return (
    <tr>
      <td>
        {cachedData ? (
          <div>
            {cachedData.name}
            <br />

            <span className="info-text">
              Scope: {cachedData.payload?.scope?.domain_name}/
              {cachedData.payload?.scope?.project_name}
              <br />
              ID: {routerId}
            </span>
          </div>
        ) : router ? (
          <div>
            {router.name}
            <br />

            <span className="info-text">
              Project: {router.project_id}
              <br />
              ID: {routerId}
            </span>
          </div>
        ) : (
          routerId
        )}
      </td>
      <td>
        {isFetching ? (
          <span>
            <span className="spinner" />
            Loading...
          </span>
        ) : router && router.subnets ? (
          router.subnets.map((subnet, i) => (
            <div key={i}>
              {subnet.name}
              <br />
              <span className="info-text">cidr: {subnet.cidr}</span>
            </div>
          ))
        ) : (
          "-"
        )}
      </td>
      <td className="snug">
        {onDelete && (
          <button
            disabled={isDeleting}
            onClick={() => {
              if (isDeleting) return
              setIsDeleting(true)
              onDelete().finally(() => setIsDeleting(false))
            }}
            className="btn btn-default btn-sm"
          >
            {isDeleting && <span className="spinner" />}
            <i className="fa fa-trash fa-fw" />
          </button>
        )}
      </td>
    </tr>
  )
}

export default Item
