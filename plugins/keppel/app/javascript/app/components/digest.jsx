const Digest = ({digest}) => {
  const [ algo, hash ] = digest.split(':');
  const shortDigest = `${algo}:${hash.slice(0, 12)}`;
  return (
    <span className='shortened-digest'>
      {shortDigest}…
      <span className='full-digest'>{digest}</span>
    </span>
  );
};

export default Digest;
