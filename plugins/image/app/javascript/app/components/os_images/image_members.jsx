import { Modal, Button } from 'react-bootstrap';
import { CSSTransition, TransitionGroup } from 'react-transition-group';
import ImageMemberItem from './image_member_item';
import ImageMemberForm from './image_member_form';

const FadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={500} classNames="css-transition-fade">
    {children}
  </CSSTransition>
);

export default class ImageMembersModal extends React.Component{
  state = {show: true, showForm: false}

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace(`/os-images/${this.props.activeTab}`)
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  toggleForm = () => {
    this.setState({showForm: !this.state.showForm})
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    if (!props.active)
      return;
    props.loadMembersOnce(props.image.id)
  }

  handleSubmit = (values) => {
    return this.props.handleSubmit(values).then(() =>
      this.setState({showForm:false})
    );
  }

  render(){
    let { image, imageMembers } = this.props

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg"
      >
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Access Control for Image {image ? image.name : ''}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { imageMembers && imageMembers.isFetching ?
            <div><span className='spinner'/>Loading...</div>
            :
            <table className='table share-rules'>
              <thead>
                <tr>
                  <th>Target Project</th>
                  <th className='snug'>Status</th>
                  <th className='snug'></th>
                </tr>
              </thead>
              <tbody>
                { !imageMembers || imageMembers.items.length==0 ? (
                  <tr><td colSpan='3'>No members found.</td></tr>
                ) : (
                  imageMembers.items.map((member,index) =>
                    <AccessControlItem
                      key={index}
                      member={member}
                      handleDelete={() => handleDelete(image.id,member.id)}/>
                  )
                )}

                <tr>
                  <td>
                    <TransitionGroup>
                      { this.state.showForm &&
                        <FadeTransition>
                          <ImageMemberForm
                            image={image}
                            handleSubmit={this.handleSubmit}/>
                        </FadeTransition>
                      }
                    </TransitionGroup>
                  </td>
                  <td></td>
                  <td>
                    <a
                      className={`btn btn-${this.state.showForm ? 'default' : 'primary'} btn-sm`}
                      href='#'
                      onClick={(e) => { e.preventDefault(); this.toggleForm()}}>
                      <i className={`fa ${this.state.showForm ? 'fa-close' : 'fa-plus'}`}/>
                    </a>
                  </td>
                </tr>
              </tbody>
            </table>
          }

        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
