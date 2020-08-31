import React from "react"
import FormInput from "../shared/FormInput"
import TagsInput from "../shared/TagsInput"
import { Button } from "react-bootstrap"
import StaticTags from "../StaticTags"

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

  console.log("RENDER NewMemberListItem")
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
