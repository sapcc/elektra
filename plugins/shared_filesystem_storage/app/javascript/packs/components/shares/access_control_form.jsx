import { Form } from 'elektra-form';

export const AccessControlForm = ({ruleForm, shareNetwork, handleSubmit, handleChange}) => {
  let rule = ruleForm.data

  const onChange=(e) => {
    if(e) e.preventDefault()
    handleChange(e.target.name,e.target.value)
  }
  const accessTypes = {
    ip: 'ip',
    user: 'user'
    // cert: 'cert'
  }

  const accessLevels = {
    ro: 'read-only',
    rw: 'read-write'
  }

  const accessToPlaceholder = () => {
    switch (rule.access_type) {
      case "ip":
        return 'IP address'
      case "user":
        return 'User or group name'
      case "cert":
        return 'TLS certificate'
      default:
        return 'Access to'
    }
  }

  const accessToInfo = () => {
    switch (rule.access_type) {
      case "ip":
        return 'A valid format is XX.XX.XX.XX or XX.XX.XX.XX/XX. For example 0.0.0.0/0.'
      case "user":
        return 'A valid value is an alphanumeric string that can contain some special characters and is from 4 to 32 characters long.'
      case "cert":
        return 'Specify the TLS identity as the IDENTKEY. A valid value is any string up to 64 characters long in the common name (CN) of the certificate. The meaning of a string depends on its interpretation. '
      default:
        return null
    }
  }

  return (
    <form className="form-inline" onSubmit={ e => { e.preventDefault(); handleSubmit() }}>
      { shareNetwork &&
        <div>{ `Network: ${shareNetwork.cidr}`}</div>
      }
      { ruleForm.errors &&
        <div className='alert alert-error'>
          <Form.Errors errors={ruleForm.errors}/>
        </div>
      }
      <div className="form-group">
        <label className='sr-only' htmlFor="access_type">Access Type</label>
        <select name="access_type" className="select required form-control" onChange={onChange}>
          <option value='Select Access Type'/>
          {
            Object.keys(accessTypes).map((accessType,index) =>
            <option value={accessType} key={accessType}>{accessTypes[accessType]}</option>
          )}
        </select>

      </div>
      <div className='form-group'>
        <label className='sr-only' htmlFor="access_to">Access To</label>
        <input
          type='text'
          className='form-control'
          placeholder={accessToPlaceholder()}
          name='access_to'
          value={rule.access_to || ''}
          onChange={onChange}/>
      </div>
      <div className='form-group'>
        <label className='sr-only' htmlFor="access_level">Access Level</label>
        <select name="access_level" className="select required form-control" onChange={onChange}>
          <option value='Select Access Level'/>
          {
            Object.keys(accessLevels).map((accessLevel,index) =>
            <option value={accessLevel} key={accessLevel}>{accessLevels[accessLevel]}</option>
          )}
        </select>
      </div>
      <div className='form-group'>
        <button
          type='submit'
          className='btn btn-primary'
          disabled={!ruleForm.isValid || ruleForm.isSubmitting}>
            { ruleForm.isSubmitting ? 'Please wait...' : 'Add' }
        </button>
      </div>
      { accessToInfo &&
        <p className='help-block'><i className="fa fa-info-circle"/>{accessToInfo()}</p>
      }
    </form>
  )
}
