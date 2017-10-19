import { connect } from  'react-redux';
import ShareEdit from '../../components/shares/edit';
import { submitEditShareForm } from '../../actions/shares';

export default connect(
  state => ({}),
  (dispatch) => (
    {
      handleSubmit: (values,{handleSuccess,handleErrors}) => (
        dispatch(submitEditShareForm(values,{handleSuccess,handleErrors}))
      )
    }
  )
)(ShareEdit);
