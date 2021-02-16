import { useState } from 'react';
import Clipboard from 'react-clipboard.js';

const Digest = ({digest, wideDisplay}) => {
  const [ isCopied, setCopied ] = useState(false);
  if (isCopied) {
    setTimeout(() => setCopied(false), 3000);
  }

  const [ algo, hash ] = digest.split(':');
  const shortDigest = wideDisplay ? digest : `${algo}:${hash.slice(0, 12)}… `;
  return (
    <span className='shortened-digest'>
      {shortDigest}
      <span className='full-digest'>
        {digest}
        <span className='digest-actions'>
          {isCopied ? (
            <button className='btn btn-link btn-xs' disabled={true}>
              <i className="fa fa-copy fa-fw"></i> Copied!
            </button>
          ) : (
            <Clipboard className='btn btn-link btn-xs' data-clipboard-text={digest} onSuccess={() => setCopied(true)}>
              <i className="fa fa-copy fa-fw"></i> Copy
            </Clipboard>
          )}
        </span>
      </span>
    </span>
  );
};

export default Digest;
