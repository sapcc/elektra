import moment from 'moment';

const isOrWas = {
  created: 'is',
  confirmed: 'is',
  greenlit: 'is',
  cancelled: 'was',
  succeeded: 'was',
  failed: 'was',
};

const sortOrderForStates = {
  created: 1,
  confirmed: 2,
  greenlit: 3,
  cancelled: 4,
  succeeded: 5,
  failed: 6,
};
const sortOrderForReasons = {
  low: 1,
  high: 2,
  critical: 3,
};

const sortKeyForStateAndReason = props => {
  const { state, reason } = props.operation;
  return sortOrderForStates[state] * 10 + sortOrderForReasons[reason];
};
const sortKeyForSizeChange = props => {
  const { old_size, new_size } = props.operation;
  return old_size * 100000 + new_size;
};

export const columns = [
  { key: 'id', label: 'Share name/ID', sortStrategy: 'text',
    sortKey: props => props.operation.asset_id },
  { key: 'state', label: 'State/Reason', sortStrategy: 'numeric',
    sortKey: sortKeyForStateAndReason },
  { key: 'size', label: 'Size', sortStrategy: 'numeric',
    sortKey: sortKeyForSizeChange },
  { key: 'timeline', label: 'Timeline', sortStrategy: 'numeric',
    sortKey: props => -props.operation.created.at },
  { key: 'actions', label: '' },
];

const titleCase = (str) => (
  str.charAt(0).toUpperCase() + str.substr(1).toLowerCase()
);
const formatTime = (event) => {
  const m = moment.unix(event.at);
  const txt = m.fromNow(true) + " ago";
  const label = m.format("LLLL");
  return <span title={label}>{txt}</span>;
};

export const CastellumOperation = ({operation}) => {
  const {
    asset_id: shareID, state, reason,
    old_size: oldSize, new_size: newSize,
    created, confirmed, greenlit, finished } = operation;

  return (
    <React.Fragment>
      <tr>
        <td className='col-md-4'>
          TODO: name
          <div className='small text-muted'>{shareID}</div>
        </td>
        <td className='col-md-2'>
          {titleCase(state)}
          <div className='small text-muted'>Usage {isOrWas[state]} {reason}</div>
        </td>
        <td className='col-md-2'>
          {oldSize} -> {newSize} GiB
        </td>
        <td className='col-md-3'>
          <div>Created: {formatTime(created)}</div>
          {confirmed && confirmed.at != created.at &&
            <div>Confirmed: {formatTime(confirmed)}</div>}
          {greenlit && greenlit.at != confirmed.at &&
            <div>Greenlit: {formatTime(greenlit)}</div>}
          {finished &&
            <div>{titleCase(state)}: {formatTime(finished)}</div>}
        </td>
        <td className='col-md-1'>
          TODO
        </td>
      </tr>
      {finished && finished.error && <tr className='castellum-error-message'>
        <td colspan='5' className='text-danger'>
          {finished.error}
        </td>
      </tr>}
    </React.Fragment>
  );
};
