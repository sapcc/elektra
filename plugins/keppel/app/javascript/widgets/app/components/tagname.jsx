import HoverCopier from './hovercopier';

const TagName = ({name, repositoryURL}) => {
  const copyActions = [
    { label: "Copy", value: name },
    { label: "Copy full URL", value: `${repositoryURL}:${name}` },
  ];
  return <HoverCopier shortText={name} longText={name} actions={copyActions} />;
};

export default TagName;
