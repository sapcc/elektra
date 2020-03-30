import { Link } from 'react-router-dom';

export const makeTabBar = (tabs, currentTab, selectTab) => (
  <nav className='nav-with-buttons'>
    <ul className='nav nav-tabs'>
      { tabs.map(tab => (
        <li key={tab.key} role='presentation' className={currentTab == tab.key ? 'active' : ''}>
          <a href="#" onClick={e => { e.preventDefault(); selectTab(tab.key); }}>{tab.label}</a>
        </li>
      ))}
    </ul>
  </nav>
);

export const makeHowtoOpener = show => (
  <li className='help-link'>
    <a href='#' onClick={e => { e.preventDefault(); show(); }}>
      <i className='fa fa-question-circle-o' />
      {' '}Instructions for Docker client
    </a>
  </li>
);

export const makeHowto = (dockerInfo, accountName, repoName, hide) => {
  const { registryDomain, userName } = dockerInfo;
  return (
    <div className='plugin-help visible'>
      <div className='bs-callout bs-callout-info bs-callout-emphasize'>
        <a className='close-button' href='#' onClick={e => { e.preventDefault(); hide(); }}>x</a>
        <h4>How to use this {repoName == '<repo>' ? 'account' : 'repository'} with Docker</h4>
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
            When the repository permits anonymous pulling, logging in is not required. Check <Link to={`/accounts/${accountName}/access_policies`}>the account's access policies</Link> for details.
          </li>
        </ol>
      </div>
    </div>
  );
};

export const makeGCNotice = objectType => (
  `${objectType} deleted. It may take a few hours for the image contents to be garbage-collected from the backing Swift container.`
);
