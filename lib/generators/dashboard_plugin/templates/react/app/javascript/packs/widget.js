import { renderWidget } from 'widget'
import * as Reducers from '../reducers';
import Container from '../application';

renderWidget(
  "%{PLUGIN_NAME}",
  Container,
  Reducers
)
