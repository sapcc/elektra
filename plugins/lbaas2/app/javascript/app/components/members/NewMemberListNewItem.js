import React, { useState } from "react";
import FormInput from "../shared/FormInput";
import TagsInput from "../shared/TagsInput";
import { Button } from "react-bootstrap";
import Select from "react-select";
import Log from "../shared/logger";
import {
  MemberIpIcon,
  MemberMonitorIcon,
  MemberRequiredField,
} from "./MemberIpIcons";
import CopyPastePopover from "../shared/CopyPastePopover";
import BooleanLabel from "../shared/BooleanLabel";

const styles = {
  container: (base) => ({
    ...base,
    flex: 1,
  }),
};

const CustomLabel = ({ htmlFor, labelText, required }) => {
  let className = "control-label" + " " + (required ? "required" : "optional");
  return (
    <label className={className} htmlFor={htmlFor}>
      {labelText}
      {required && <abbr title="required">*</abbr>}
    </label>
  );
};

const NewMemberListNewItem = ({
  member,
  index,
  onRemoveMember,
  results,
  servers,
}) => {
  const [selectedServers, setSelectedServers] = useState([]);

  const onRemoveClick = (e) => {
    onRemoveMember(member.id);
  };

  const shouldAlert = () => {
    if (results) {
      return results.saved == false;
    }
    return false;
  };

  const monitorAddressPort = () => {
    if (member.monitor_address || member.monitor_port) {
      return `${member.monitor_address}:${member.monitor_port}`;
    }
  };

  const onChangeServers = () => {};

  Log.debug("RENDER NewMemberListExistingItem");
  return (
    <tr>
      <td>
        <div className="row">
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][name]`}
              labelText="Servers"
            />
          </div>
          <div className="col-md-11">
            <Select
              className="basic-single server-select"
              classNamePrefix="select"
              isDisabled={false}
              isLoading={servers.isLoading}
              isClearable={true}
              isRtl={false}
              isSearchable={true}
              name="servers"
              onChange={onChangeServers}
              options={servers.items}
              isMulti={false}
              closeMenuOnSelect={true}
              styles={styles}
              value={selectedServers}
              placeholder="Fill member with data from a existing server"
            />
          </div>
        </div>

        <div className="row margin-top">
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][name]`}
              labelText="Name"
              required
            />
          </div>
          <div className="col-md-6">
            <FormInput
              name={`member[${member.id}][name]`}
              value={member.name}
            />
          </div>
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][tags]`}
              labelText="Tags"
            />
          </div>
          <div className="col-md-4">
            <TagsInput
              name={`member[${member.id}][tags]`}
              initValue={member.tags}
            />
          </div>
        </div>

        <div className="row margin-top">
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][address]`}
              labelText="IPs"
              required
            />
          </div>
          <div className="col-md-6">
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
          </div>
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][weight]`}
              labelText="Weight"
            />
          </div>
          <div className="col-md-4">
            <FormInput
              type="number"
              name={`member[${member.id}][weight]`}
              value={member.weight || 1}
            />
          </div>
        </div>

        <div className="row margin-top">
          <div className="col-md-1"></div>
          <div className="col-md-6">
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
          </div>
          <div className="col-md-1">
            <CustomLabel
              htmlFor={`member[${member.id}][backup]`}
              labelText="Backup"
            />
          </div>
          <div className="col-md-4">
            <FormInput
              type="checkbox"
              name={`member[${member.id}][backup]`}
              value={member.backup}
            />
          </div>
        </div>
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
