import { renderWidget } from 'widget'
import * as Reducers from '../reducers';
import Container from '../application';

renderWidget(
  'shared_filesystem_storage',
  Container,
  Reducers
)
