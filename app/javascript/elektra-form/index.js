// export { FormElement, FormElementHorizontal } from './components/form_element';
// export { FormInput } from './components/form_input';
// export { SubmitButton } from './components/submit_button';
// export { FormErrors } from './components/form_errors';

import { Form } from './components/form';
import { FormInput } from './components/form_input';
import { FormElement, FormElementHorizontal } from './components/form_element';
import { FormErrors } from './components/form_errors';
import { SubmitButton } from './components/submit_button';

Form.Element = FormElement;
Form.ElementHorizontal = FormElementHorizontal;
Form.Input = FormInput;
Form.Errors = FormErrors;
Form.SubmitButton = SubmitButton;

export { Form };
