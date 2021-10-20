import React, { useState } from "react";
import FormInput from "../shared/FormInput";
import TagsInput from "../shared/TagsInput";
import { Button } from "react-bootstrap";
import uniqueId from "lodash/uniqueId";
import Select from "react-select";
import Log from "../shared/logger";
import {
  MemberIpIcon,
  MemberMonitorIcon,
  MemberRequiredField,
} from "./MemberIpIcons";

const styles = {
  container: (base) => ({
    ...base,
    flex: 1,
  }),
  menuPortal: (provided) => ({ ...provided, zIndex: 9999 }),
  menu: (provided) => ({ ...provided, zIndex: 9999 }),
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
  const [name, setName] = useState(member.name);
  const [address, setAddress] = useState(member.address);
  const [showServers, setShowServers] = useState(false);

  const onRemoveClick = (e) => {
    onRemoveMember(member.id);
  };

  const shouldAlert = () => {
    if (results) {
      return results.saved == false;
    }
    return false;
  };

  const onChangeServers = (values) => {
    setSelectedServers(values);
    setName(values.name);
    setAddress(values.address);
  };

  const collapseId = uniqueId("collapseServerSelect-");

  Log.debug("RENDER NewMemberListExistingItem");
  return (
    <>
      {index > 0 && <hr />}
      <div className="row display-flex">
        <div className="col-md-12">
          <div className="row">
            <div className="col-md-1"></div>
            <div className="col-md-11">
              <div className="display-flex">
                <div
                  className="collapse-trigger"
                  onClick={() => setShowServers(!showServers)}
                  data-toggle="collapse"
                  data-target={`#${collapseId}`}
                  aria-expanded={showServers}
                  aria-controls={collapseId}
                >
                  {showServers ? (
                    <>
                      <span>Choose name and IP from an existing server</span>
                      <i className="fa fa-chevron-circle-up" />
                    </>
                  ) : (
                    <>
                      <span>Choose name and IP from an existing server</span>
                      <i className="fa fa-chevron-circle-down" />
                    </>
                  )}
                </div>
              </div>
              <div className="collapse margin-top" id={collapseId}>
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
                  placeholder="Select..."
                />
              </div>
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
              <FormInput name={`member[${member.id}][name]`} value={name} />
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
                  value={address}
                  placeholder="IP Address"
                  extraClassName="icon-in-input"
                />
                <span className="horizontal-padding-min">:</span>
                <FormInput
                  type="number"
                  name={`member[${member.id}][protocol_port]`}
                  value={member.protocol_port}
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
              <div className="display-flex member-icon-in-input">
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
        </div>
      </div>
    </>
  );
};

export default NewMemberListNewItem;
