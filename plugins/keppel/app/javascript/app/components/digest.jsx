import HoverCopier from './hovercopier';

const Digest = ({digest, wideDisplay}) => {
  const [ algo, hash ] = digest.split(':');
  const shortDigest = wideDisplay ? digest : `${algo}:${hash.slice(0, 12)}… `;

  const copyActions = [
    {label: "Copy", value: digest},
  ];

  return <HoverCopier shortText={shortDigest} longText={digest} actions={copyActions} />;
};

export default Digest;
