import React from "react";
import FormInput from "../shared/FormInput";
import TagsInput from "../shared/TagsInput";
import { Button } from "react-bootstrap";
import StaticTags from "../StaticTags";
import Log from "../shared/logger";
import { MemberIpIcon, MemberMonitorIcon } from "./MemberIpIcons";
import CopyPastePopover from "../shared/CopyPastePopover";

const NewMemberListItem = ({ member, index, onRemoveMember, results }) => {
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

  Log.debug("RENDER NewMemberListItem");
  return (
    <tr>
      <td className="centered">
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
          <span>{displayName()}</span>
        ) : (
          <div className="form-margin-top">
            <FormInput
              name={`member[${member.id}][name]`}
              value={member.name}
            />
          </div>
        )}
      </td>
      <td>
        {member.saved ? (
          <>
            <p className="list-group-item-text list-group-item-text-copy display-flex">
              <MemberIpIcon />
              {member.address}:{member.protocol_port}
            </p>
            {monitorAddressPort() && (
              <p className="list-group-item-text list-group-item-text-copy display-flex">
                <MemberMonitorIcon />
                {monitorAddressPort()}
              </p>
            )}
          </>
        ) : (
          <>
            <p className="nowrap">
              <abbr className="snug" title="required">
                *
              </abbr>
              <MemberIpIcon />
              Address/Protocol Port
            </p>
            <div className="display-flex ">
              <FormInput
                name={`member[${member.id}][address]`}
                value={member.address}
                disabled={member.edit}
                // size="md"
              />
              <span className="horizontal-padding-min">:</span>
              <FormInput
                type="number"
                name={`member[${member.id}][protocol_port]`}
                value={member.protocol_port}
                disabled={member.edit}
                size="md"
              />
            </div>
            <p className="nowrap">
              <MemberMonitorIcon />
              Monitor Address/Port
            </p>
            <div className="display-flex ">
              <FormInput
                name={`member[${member.id}][monitor_address]`}
                value={member.monitor_address}
                // size="md"
              />
              <span className="horizontal-padding-min">:</span>
              <FormInput
                type="number"
                name={`member[${member.id}][monitor_port]`}
                value={member.monitor_port}
                size="md"
              />
            </div>
          </>
        )}
      </td>
      <td>
        {member.saved ? (
          <span>{member.weight}</span>
        ) : (
          <div className="form-margin-top">
            <FormInput
              type="number"
              name={`member[${member.id}][weight]`}
              value={member.weight || 1}
            />
          </div>
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
          <div className="form-margin-top">
            <FormInput
              type="checkbox"
              name={`member[${member.id}][backup]`}
              value={member.backup}
            />
          </div>
        )}
      </td>
      <td>
        {member.saved ? (
          <StaticTags tags={member.tags} shouldPopover={true} />
        ) : (
          <div className="form-margin-top">
            <TagsInput
              name={`member[${member.id}][tags]`}
              initValue={member.tags}
            />
          </div>
        )}
      </td>
      <td className="centered">
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
  );
};

export default NewMemberListItem;
