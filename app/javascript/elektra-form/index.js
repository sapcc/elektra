// export { FormElement, FormElementHorizontal } from './components/form_element';
// export { FormInput } from './components/form_input';
// export { SubmitButton } from './components/submit_button';
// export { FormErrors } from './components/form_errors';

import { FormProvider } from './components/form_provider';
import { FormInput } from './components/form_input';
import { FormElement, FormElementHorizontal } from './components/form_element';
import { FormErrors } from './components/form_errors';
import { SubmitButton } from './components/submit_button';

let Form = {};
Form.Provider = FormProvider
Form.Element = FormElement;
Form.ElementHorizontal = FormElementHorizontal;
Form.Input = FormInput;
Form.Errors = FormErrors;
Form.SubmitButton = SubmitButton;

export { Form };
