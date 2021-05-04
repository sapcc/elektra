import React from "react"
import FormInput from "../shared/FormInput"
import TagsInput from "../shared/TagsInput"
import { Button } from "react-bootstrap"
import StaticTags from "../StaticTags"
import Log from "../shared/logger"

const NewMemberListItem = ({ member, index, onRemoveMember, results }) => {
  const onRemoveClick = (e) => {
    onRemoveMember(member.id)
  }

  const shouldAlert = () => {
    if (results) {
      return results.saved == false
    }
    return false
  }

  Log.debug("RENDER NewMemberListItem")
  return (
    <tr>
      <td>
        <div className={shouldAlert() ? "text-danger" : ""}>
          {shouldAlert() ? (
            <span>
              <strong>{index}</strong>
            </span>
          ) : (
            <span>{index}</span>
          )}
        </div>
        {!member.saved && (
          <React.Fragment>
            <FormInput
              type="hidden"
              name={`member[${member.id}][identifier]`}
              value={member.id}
            />
            <FormInput
              type="hidden"
              name={`member[${member.id}][index]`}
              value={index}
            />
          </React.Fragment>
        )}
      </td>
      <td>
        {member.saved ? (
          <span>{member.name}</span>
        ) : (
          <FormInput name={`member[${member.id}][name]`} value={member.name} />
        )}
      </td>
      <td>
        {member.saved ? (
          <span>{member.address}</span>
        ) : (
          <React.Fragment>
            <FormInput
              name={`member[${member.id}][address]`}
              value={member.address}
              disabled={member.edit}
            />
          </React.Fragment>
        )}
      </td>
      <td>
        {member.saved ? (
          <span>{member.protocol_port}</span>
        ) : (
          <FormInput
            type="number"
            name={`member[${member.id}][protocol_port]`}
            value={member.protocol_port}
            disabled={member.edit}
          />
        )}
      </td>
      <td>
      {member.saved ? (
          <div className="display-flex ">
            <span>{member.monitor_address}</span>
            {member.monitor_address &&
              <span className="horizontal-padding-min">/</span>
            }
            <span>{member.monitor_port}</span>
          </div>
        ) : (
          <div className="display-flex ">
            <FormInput
              name={`member[${member.id}][monitor_address]`}
              value={member.monitor_address}
              size="md"
            />
            <span className="horizontal-padding-min">/</span>
            <FormInput
              type="number"
              name={`member[${member.id}][monitor_port]`}
              value={member.monitor_port}
              size="sm"
            />
          </div>           
        )}        
      </td>
      <td>
        {member.saved ? (
          <span>{member.weight}</span>
        ) : (
          <FormInput
            type="number"
            name={`member[${member.id}][weight]`}
            value={member.weight || 1}
          />
        )}
      </td>
      <td>
        {member.saved ? (
          <React.Fragment>
            {member.backup ? (
              <i className="fa fa-check" />
            ) : (
              <i className="fa fa-times" />
            )}
          </React.Fragment>
        ) : (
          <FormInput
            type="checkbox"
            name={`member[${member.id}][backup]`}
            value={member.backup}
          />
        )}
      </td>
      <td>
        {member.saved ? (
          <StaticTags tags={member.tags} shouldPopover={true} />
        ) : (
          <TagsInput
            name={`member[${member.id}][tags]`}
            initValue={member.tags}
          />
        )}
      </td>
      <td>
        {onRemoveMember && (
          <React.Fragment>
            {!member.saved && (
              <Button bsStyle="link" onClick={onRemoveClick}>
                <i className="fa fa-minus-circle"></i>
              </Button>
            )}
          </React.Fragment>
        )}
      </td>
    </tr>
  )
}

export default NewMemberListItem
