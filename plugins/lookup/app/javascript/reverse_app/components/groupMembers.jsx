const GroupMembers = props => (
  <React.Fragment>
    {props.members.isFetching &&
      <span className="spinner" />
    }
    {props.members.error &&
      <span className="text-danger">{props.members.error.error}</span>
    }
    {props.members.data &&
      <React.Fragment>
        {props.members.data.name}
        <small className="text-muted"> ( {props.members.data.id} )</small>
      </React.Fragment>
    }
  </React.Fragment>
);

export default GroupMembers;
