import { renderWidget } from 'widget'
import * as Reducers from '../reducers';
import Container from '../application';

renderWidget(
  document.currentScript,
  'shared_filesystem_storage',
  Reducers,
  Container
)
