import { FormInput } from './components/form_input';
import {
  FormElement,
  FormElementHorizontal,
  FormElementInline
} from './components/form_element';
import { FormErrors } from './components/form_errors';
import { SubmitButton } from './components/submit_button';
import Form from './components/form';

Form.Element = FormElement;
Form.ElementHorizontal = FormElementHorizontal;
Form.ElementInline= FormElementInline;
Form.Input = FormInput;
Form.Errors = FormErrors;
Form.SubmitButton = SubmitButton;

export { Form };
