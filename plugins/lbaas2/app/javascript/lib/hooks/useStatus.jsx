import React from "react";
import StateLabel from "../../app/components/shared/StateLabel";
import StatusLabel from "../../app/components/shared/StatusLabel";

export const operationStatusOptions = (option) => {
  switch (option) {
    case "ONLINE":
      return {
        labelClassName: "label-success",
        textClassName: "text-success",
        title: (
          <React.Fragment>
            <ul className="label-tooltip">
              <li>Entity is operating normally</li>
              <li>All pool members are healthy</li>
            </ul>
          </React.Fragment>
        ),
      };

    case "DRAINING":
      return {
        labelClassName: "label-warning-greyscale",
        textClassName: "text-warning-greyscale",
        title: "The member is not accepting new connections",
      };
    case "DEGRADED":
      return {
        labelClassName: "label-warning-greyscale",
        textClassName: "text-warning-greyscale",
        title: "One or more of the entity’s components are in ERROR",
      };
    case "OFFLINE":
      return {
        labelClassName: "label-warning-greyscale",
        textClassName: "text-warning-greyscale",
        title: "Entity is administratively disabled",
      };
    case "NO_MONITOR":
      return {
        labelClassName: "label-warning-greyscale",
        textClassName: "text-warning-greyscale",
        title:
          "No health monitor is configured for this entity and it’s status is unknown",
      };

    case "ERROR":
      return {
        labelClassName: "label-warning-greyscale",
        textClassName: "text-warning-greyscale",
        title: (
          <React.Fragment>
            <ul className="label-tooltip">
              <li>The entity has failed</li>
              <li>The member is failing it’s health monitoring checks</li>
              <li>All of the pool members are in ERROR</li>
            </ul>
          </React.Fragment>
        ),
      };
    default:
      return {
        labelClassName: "label-info",
        textClassName: "text-info",
        title: "Unknown state",
      };
  }
};

export const provisioningStatusOptions = (option) => {
  switch (option) {
    case "ACTIVE":
      return {
        labelClassName: "label-success",
        textClassName: "text-success",
        title: "The entity was provisioned successfully",
      };
    case "DELETED":
      return {
        labelClassName: "label-success",
        textClassName: "text-success",
        title: "The entity has been successfully deleted",
      };

    case "ERROR":
      return {
        labelClassName: "label-danger",
        textClassName: "text-danger",
        title: "Provisioning failed",
      };

    case "PENDING_CREATE":
      return {
        labelClassName: "label-warning",
        textClassName: "text-warning",
        title: "The entity is being created",
      };
    case "PENDING_UPDATE":
      return {
        labelClassName: "label-warning",
        textClassName: "text-warning",
        title: "The entity is being updated",
      };
    case "PENDING_DELETE":
      return {
        labelClassName: "label-warning",
        textClassName: "text-warning",
        title: "The entity is being deleted",
      };
    default:
      return {
        labelClassName: "label-info",
        textClassName: "text-info",
        title: "Unknown state",
      };
  }
};

const operatingStatusLable = (label) => {
  if (label == "ERROR") {
    return "OFFLINE";
  }
  return label;
};

const useStatus = (operatingStatus, provisioningStatus, options) => {
  const entityStatus = React.useMemo(() => {
    const opStatusOptions = operationStatusOptions(operatingStatus);
    const provStatusOptions = provisioningStatusOptions(provisioningStatus);

    const stateLabelTooltipContent = () => {
      // add extra error options if this option is set. Used in pools section
      if (
        options &&
        options.operatingStatusErrorExtraTitle &&
        operatingStatus === "ERROR"
      ) {
        return (
          <>
            <ul className="label-tooltip extra-title">
              <li>{options.operatingStatusErrorExtraTitle}</li>
            </ul>
            {opStatusOptions.title}
          </>
        );
      }
      return opStatusOptions.title;
    };

    return (
      <>
        <StateLabel
          label={operatingStatusLable(operatingStatus)}
          labelClassName={opStatusOptions.labelClassName}
          tooltipContent={stateLabelTooltipContent()}
        />
        {provisioningStatus !== "ACTIVE" && (
          <>
            <br />
            <StatusLabel
              label={provisioningStatus}
              textClassName={provStatusOptions.textClassName}
              title={provStatusOptions.title}
            />
          </>
        )}
      </>
    );
  }, [operatingStatus, provisioningStatus]);

  return {
    entityStatus,
  };
};

export default useStatus;
