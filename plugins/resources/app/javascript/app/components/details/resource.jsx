import { Scope } from '../../scope';
import { Unit, valueWithUnit } from '../../unit';
import { buttonCaption } from '../../utils';

export default class DetailsResource extends React.Component {
  state = {
    //This is `null` while not editing, and contains the content of the <input> while editing.
    editText: null,
    isSubmitting: false,
  }

  constructor(props) {
    super(props);
    this.inputRef = React.createRef();
  }
  componentDidUpdate() {
    const input = this.inputRef.current;
    if (input) input.focus();
  }

  handleKeyPress(e) {
    if (e.key == 'Enter') {
      this.submit();
      e.stopPropagation();
    }
    return true;
  }

  handleInput(e) {
    this.setState({
      ...this.state,
      editText: e.target.value,
    });
  }

  startEditing() {
    const { quota, unit: unitName } = this.props.resource;
    const unit = new Unit(unitName);
    this.setState({
      ...this.state,
      editText: unit.format(quota, { ascii: true }),
      isSubmitting: false,
    });
  }

  stopEditing() {
    this.setState({
      ...this.state,
      editText: null,
      isSubmitting: false,
    });
  }

  submit() {
    //validate input
    const { unit: unitName } = this.props.resource;
    const unit = new Unit(unitName);
    const parsedValue = unit.parse(this.state.editText);
    if (parsedValue.error) {
      const scope = new Scope(this.props.scopeData);
      this.props.handleAPIErrors(scope.formatInputError(parsedValue.error, unitName));
      return;
    }

    this.setState({
      ...this.state,
      isSubmitting: true,
    });
    this.props.setQuota(this.props.metadata.id, parsedValue)
      .then(() => this.stopEditing())
      .catch(() => this.setState({ ... this.state, isSubmitting: false }));
  }

  render() {
    const { name: scopeName, id: scopeID } = this.props.metadata;

    const { quota, projects_quota: projectsQuota, usage, burst_usage: burstUsage, unit: unitName } = this.props.resource;
    const unit = new Unit(unitName);

    const { canEdit } = this.props;
    const { editText, isSubmitting } = this.state;
    const isEditing = editText != null;

    //assemble scopeData for the subscope described by this <DetailsResource/>
    const parentScope = new Scope(this.props.scopeData);
    const scopeData = parentScope.descendIntoSubscope(scopeID);
    const scope = new Scope(scopeData);

    //NOTE: The buttons in the last column have key attributes on them to
    //ensure that the DOM nodes get replaced when flipping back and forth
    //between Edit/Jump and Save/Cancel. Otherwise, a click on "Cancel" would
    //cause a Jump since the button flips back to "Jump" while being clicked.
    return (
      <tr>
        <td className='col-md-3'>
          {scopeName}
          <div className='small text-muted'>{scopeID}</div>
        </td>
        <td className='col-md-2'>
          {isEditing
            ? (
              <div className='input-group'>
                <input type='text' value={editText} disabled={isSubmitting}
                  className='form-control' ref={this.inputRef}
                  onKeyPress={e => this.handleKeyPress(e)}
                  onChange={e => this.handleInput(e)}
                />
              </div>
            ) : valueWithUnit(quota, unit)}
        </td>
        {scope.isDomain() && <td className='col-md-2'>{valueWithUnit(projectsQuota, unit)}</td>}
        <td className={scope.isDomain() ? 'col-md-1' : 'col-md-2'}>{valueWithUnit(usage, unit)}</td>
        <td className={scope.isDomain() ? 'col-md-1' : 'col-md-2'}>{valueWithUnit(burstUsage || 0, unit)}</td>
        <td className='col-md-3'>
          {isEditing
            ? (
              <React.Fragment>
                <a key='save' onClick={() => this.submit()} disabled={isSubmitting} className='btn btn-primary btn-sm'>{buttonCaption('Save', isSubmitting)}</a>
                {' '}
                <a key='cancel' onClick={() => this.stopEditing()} disabled={isSubmitting} className='btn btn-sm'>Cancel</a>
              </React.Fragment>
            ) : (
              <React.Fragment>
                {canEdit && <a key='edit' onClick={() => this.startEditing()} className='btn btn-default btn-sm'>Edit</a>}
                {canEdit && ' '}
                <a key='jump' href={scope.elektraUrlPath()} target='_blank' className='btn btn-default btn-sm' title={`Go to Resource Management for this ${scope.level()} in a new tab`}>Jump</a>
              </React.Fragment>
            )
          }
        </td>
      </tr>
    );
  }
}
