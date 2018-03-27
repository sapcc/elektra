export default ({handleDelete, member}) => {
  return (
    <tr className={ member.isDeleting && 'updating' }>
      <td>{member.target}</td>
      <td>{member.state}</td>
      <td className='snug'>
        <button className='btn btn-danger btn-sm' onClick={(e) => { e.preventDefault(); handleDelete()}}>
          <i className='fa fa-minus'/>
        </button>
      </td>
    </tr>
  )
}
