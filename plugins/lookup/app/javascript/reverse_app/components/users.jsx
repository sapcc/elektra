const Users = props => (
  <ul>
    {Object.keys(props.users).map(key => (
      <li>{props.users[key]}</li>
    ))}
  </ul>
);

export default Users;
