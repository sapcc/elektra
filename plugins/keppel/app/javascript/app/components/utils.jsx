import { Link } from 'react-router-dom';

export const makeTabBar = (tabs, currentTab, selectTab) => (
  <nav className='nav-with-buttons'>
    <ul className='nav nav-tabs'>
      { tabs.map(tab => (
        <li key={tab.key} role='presentation' className={currentTab == tab.key ? 'active' : ''}>
          <a onClick={() => selectTab(tab.key)}>{tab.label}</a>
        </li>
      ))}
    </ul>
  </nav>
);

export const makeHowto = (dockerInfo, accountName, repoName) => {
  const { registryDomain, userName } = dockerInfo;
  return (
    <ol className='howto'>
      <li>
        Log in with your OpenStack credentials:
        <pre><code>
          {`$ docker login ${registryDomain}\nUsername: `}
          <strong>{userName}</strong>
          {`\nPassword: `}
          <strong>{`<your password>`}</strong>
        </code></pre>
      </li>
      <li>
        To push an image, use this command:
        <pre><code>{`$ docker push ${registryDomain}/${accountName}/${repoName}:<tag>`}</code></pre>
      </li>
      <li>
        To pull an image, use this command:
        <pre><code>{`$ docker pull ${registryDomain}/${accountName}/${repoName}:<tag>`}</code></pre>
        When the repository permits anonymous pulling, logging in is not required. Check <Link to={`/accounts/${accountName}/policies`}>the account's access policies</Link> for details.
      </li>
    </ol>
  );
};
