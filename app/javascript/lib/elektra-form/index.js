import { FormInput } from './components/form_input';
import { FormMultiselect } from './components/form_multiselect';
import {
  FormElement,
  FormElementHorizontal,
  FormElementInline
} from './components/form_element';
import { FormErrors } from './components/form_errors';
import { SubmitButton } from './components/submit_button';
import { ErrorsList } from './components/errors_list';
import Form from './components/form';

Form.Element = FormElement;
Form.ElementHorizontal = FormElementHorizontal;
Form.ElementInline= FormElementInline;
Form.Input = FormInput;
Form.Errors = FormErrors;
Form.SubmitButton = SubmitButton;
Form.FormMultiselect = FormMultiselect;

export { Form, ErrorsList };
