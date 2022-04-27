const Parent = props => (
  <span>
    <span>{props.name}</span>
    <small className="text-muted"> ( {props.id} )</small>
  </span>
);

export default Parent;
