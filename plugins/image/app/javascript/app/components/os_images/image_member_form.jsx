// import { Form } from 'lib/elektra-form';
import { AsyncTypeahead, Highlighter } from 'react-bootstrap-typeahead'
//
// export default class AccessControlForm extends React.Component {
//   state = {
//     show: true
//   }
//
//   validate = (values) => {
//     return values.project_id && true
//   }
//
//   handleSubmit = (values) => {
//     return true
//   }
//
//   handleToggle = () => {
//     this.setState({show: !this.state.show})
//   }
//
//   render() {
//     return (
//       <Form
//         validate={this.validate}
//         className='form form-inline'
//         onSubmit={this.handleSubmit}>
//
//         <Form.Errors/>
//
//         <Form.ElementInline label='Project' name="project_id" labelClass='sr-only'>
//
//           <Form.Input
//             ref={ (input) => {this.target = input} }
//             onClick={this.handleToggle}
//             elementType='input'
//             name='project_id'
//             autoComplete='false'
//             placeholder='Project (name or ID) with whom the image is shared.'/>
//
//           <Overlay
//             show={this.state.show}
//             placement="bottom"
//             onHide={() => this.setState({ show: false })}
//             target={() => ReactDOM.findDOMNode(this.target)}>
//             <MenuItem eventKey="1">Red</MenuItem>
//             <MenuItem eventKey="2">Blue</MenuItem>
//             <MenuItem eventKey="3" active>
//               Orange
//             </MenuItem>
//             <MenuItem eventKey="1">Red-Orange</MenuItem>
//           </Overlay>
//         </Form.ElementInline>
//
//         <div className='form-group'>
//           <Form.SubmitButton label='Add'/>
//         </div>
//       </Form>
//     )
//   }
// }

// function CustomPopover({ style }) {
//   return (
//     <div className='open'>
//       <ul className='dropdown-menu'>
//         <MenuItem header>Header</MenuItem>
//         <MenuItem>link</MenuItem>
//         <MenuItem divider />
//         <MenuItem header>Header</MenuItem>
//         <MenuItem>link</MenuItem>
//         <MenuItem disabled>disabled</MenuItem>
//         <MenuItem title="See? I have a title.">link with title</MenuItem>
//       </ul>
//     </div>
//   );
// }
//
// export default class Example extends React.Component {
//   constructor(props, context) {
//     super(props, context);
//
//     this.handleToggle = this.handleToggle.bind(this);
//
//     this.state = {
//       show: true
//     };
//   }
//
//   handleToggle() {
//     this.setState({ show: !this.state.show });
//   }
//
//   render() {
//     return (
//       <div style={{ height: 100, position: 'relative' }}>
//         <Button
//           ref={button => {
//             this.target = button;
//           }}
//           onClick={this.handleToggle}
//         >
//           I am an Overlay target
//         </Button>
//
//         <Overlay
//           show={this.state.show}
//           onHide={() => this.setState({ show: false })}
//           placement="bottom"
//           container={this}
//           target={() => ReactDOM.findDOMNode(this.target)}
//         >
//           <CustomPopover />
//         </Overlay>
//       </div>
//     );
//   }
// }

export default class AccessControlForm extends React.Component {
  state = {
    allowNew: false,
    isLoading: false,
    multiple: false,
    options: [],
  }

  handleSearch = (searchTerm) => {
    console.log('searchTerm',searchTerm)
    const options = [
      {name: 'Andreas', id: '12fbf16e217d74cec805a4f476b2bc306'},
      {name: 'Anton', id: '22fbf16e217d74cec805a4f476b2bc306'},
      {name: 'Albert', id: '32fbf16e217d74cec805a4f476b2bc306'},
      {name: 'Bern', id: '42fbf16e217d74cec805a4f476b2bc306'},
      {name: 'Gustav', id: '52fbf16e217d74cec805a4f476b2bc306'},
      {name: 'Ute', id: '62fbf16e217d74cec805a4f476b2bc306'}
    ]
    this.setState({isLoading: true, options:[]})
    setTimeout((() => this.setState({isLoading: false, options:options})), 1000)

  }

  render() {
    return (
      <React.Fragment>
        <div className="input-group">
          <AsyncTypeahead
            {...this.state}
            onChange={(selected) => { console.log(selected) }}
            onSearch={this.handleSearch}
            labelKey="name"
            placeholder="Project name or ID"
            renderMenuItemChildren={(option, props, index) => {
              console.log('option',option,'props',props,'index',index)
              //return <span>{option.name} (<span className='info-text'>{option.id}</span>)</span>
              return [
                <Highlighter key="name" search={props.text}>
                  {option.name}
                </Highlighter>,
                <div className='info-text' key="id">
                  <small>ID: {option.id}</small>
                </div>
              ]
            }
            }
          />
          <span className="input-group-btn">
            <button className="btn btn-primary" type="button">Add</button>
          </span>
        </div>
        <p className="help-block">
          <i className="fa fa-info-circle"></i>
          Project (name or ID) with whom the image is shared.
        </p>
      </React.Fragment>
    );
  }
}
