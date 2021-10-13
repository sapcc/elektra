import React from "react";
import FormInput from "../shared/FormInput";
import TagsInput from "../shared/TagsInput";
import { Button } from "react-bootstrap";
import Log from "../shared/logger";
import { Form } from "lib/elektra-form";
import {
  MemberIpIcon,
  MemberMonitorIcon,
  MemberRequiredField,
} from "./MemberIpIcons";
import CopyPastePopover from "../shared/CopyPastePopover";
import BooleanLabel from "../shared/BooleanLabel";

const NewMemberListNewItem = ({ member, index, onRemoveMember, results }) => {
  const onRemoveClick = (e) => {
    onRemoveMember(member.id);
  };

  const shouldAlert = () => {
    if (results) {
      return results.saved == false;
    }
    return false;
  };

  const displayName = () => {
    return (
      <CopyPastePopover
        text={member.name}
        size={20}
        sliceType="MIDDLE"
        shouldCopy={false}
      />
    );
  };

  const monitorAddressPort = () => {
    if (member.monitor_address || member.monitor_port) {
      return `${member.monitor_address}:${member.monitor_port}`;
    }
  };

  Log.debug("RENDER NewMemberListExistingItem");
  return (
    <tr>
      <td>
        <Form.ElementHorizontal
          label="Name"
          name={`member[${member.id}][name]`}
          required
        >
          <FormInput name={`member[${member.id}][name]`} value={member.name} />
        </Form.ElementHorizontal>

        <Form.ElementHorizontal label="IPs">
          <div className="display-flex member-icon-in-input member-required-icon">
            <MemberIpIcon />
            <FormInput
              name={`member[${member.id}][address]`}
              value={member.address}
              disabled={member.edit}
              placeholder="IP Address"
              extraClassName="icon-in-input"
            />
            <span className="horizontal-padding-min">:</span>
            <FormInput
              type="number"
              name={`member[${member.id}][protocol_port]`}
              value={member.protocol_port}
              disabled={member.edit}
              placeholder="Port"
              size="lg"
            />
          </div>
          <div className="display-flex member-icon-in-input margin-top">
            <MemberMonitorIcon />
            <FormInput
              name={`member[${member.id}][monitor_address]`}
              value={member.monitor_address}
              placeholder="Alternate Monitor IP"
              extraClassName="icon-in-input"
            />
            <span className="horizontal-padding-min">:</span>
            <FormInput
              type="number"
              name={`member[${member.id}][monitor_port]`}
              value={member.monitor_port}
              placeholder="Port"
              size="lg"
            />
          </div>
        </Form.ElementHorizontal>

        <Form.ElementHorizontal
          label="Weight"
          name={`member[${member.id}][weight]`}
        >
          <FormInput
            type="number"
            name={`member[${member.id}][weight]`}
            value={member.weight || 1}
          />
        </Form.ElementHorizontal>

        <Form.ElementHorizontal
          label="Backup"
          name={`member[${member.id}][backup]`}
        >
          <FormInput
            type="checkbox"
            name={`member[${member.id}][backup]`}
            value={member.backup}
          />
        </Form.ElementHorizontal>

        <Form.ElementHorizontal
          label="Tags"
          name={`member[${member.id}][tags]`}
        >
          <TagsInput
            name={`member[${member.id}][tags]`}
            initValue={member.tags}
          />
        </Form.ElementHorizontal>
      </td>
      <td className="centered">
        {onRemoveMember && (
          <React.Fragment>
            <Button bsStyle="link" onClick={onRemoveClick}>
              <i className="fa fa-minus-circle"></i>
            </Button>
          </React.Fragment>
        )}
      </td>
    </tr>
  );
};

export default NewMemberListNewItem;
