import { renderWidget } from 'widget'
import * as Reducers from '../reducers';
import Container from '../application';

import { addNotice, addError } from 'lib/flashes';

renderWidget(
  document.currentScript,
  'shared_filesystem_storage',
  Reducers,
  Container
)
