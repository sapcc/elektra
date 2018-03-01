export default ({event}) =>
  <tr>
    <td colSpan='6'>
      { event.isFetchingDetails ?
        <span className='spinner'/>
        :
        <pre>{JSON.stringify(event.details, null, 2)}</pre>
      }
    </td>
  </tr>     
