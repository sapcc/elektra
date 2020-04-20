import React from 'react';
import CopyPastePopover from '../shared/CopyPastePopover'
import StateLabel from '../StateLabel'
import StaticTags from '../StaticTags';
import useL7Policy from '../../../lib/hooks/useL7Policy'
import { Link } from 'react-router-dom';

const L7PolicySelected = ({l7Policy, tableScroll, onBackLink}) => {
  const {actionRedirect, reset} = useL7Policy()

  const handleDelete = () => {
  }


  return (
    <React.Fragment>
      <div className="multiple-subtable-head">
        <div className="row multiple-subtable-head-content">
          <div className="col-md-12">

            <div className="display-flex">
              <Link className="back-link" to="#" onClick={onBackLink}>
                <i className="fa fa-chevron-circle-left"></i>
                Back to L7 Policies
              </Link>
              <div className='btn-group btn-right'>
                <button
                  className='btn btn-default btn-sm dropdown-toggle'
                  type="button"
                  data-toggle="dropdown"
                  aria-expanded={true}>
                  <span className="fa fa-cog"></span>
                </button>
                <ul className="dropdown-menu dropdown-menu-right" role="menu">
                  <li><a href='#' onClick={handleDelete}>Delete</a></li>
                </ul>
              </div>
            </div>

          </div>
        </div>
      </div>

      <div className="multiple-subtable-body">
        <div className="multiple-subtable-entry">
        <div className="row">
            <div className="col-md-12">
              <b>Name/ID:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              {l7Policy.name || l7Policy.id}
            </div>
          </div>
          {l7Policy.name && 
            <div className="row">
              <div className="col-md-12 text-nowrap">
              <small className="info-text">{<CopyPastePopover text={l7Policy.id} size={50} sliceType="MIDDLE" bsClass="cp copy-paste-ids" shouldClose={tableScroll}/>}</small>
              </div>                
            </div>
          }
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Description:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              {l7Policy.description}
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>State:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <StateLabel placeholder={l7Policy.operating_status} path="" />
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Prov. Status:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <StateLabel placeholder={l7Policy.provisioning_status} path="" />
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Tags:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <StaticTags tags={l7Policy.tags} />
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Position:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              {l7Policy.position}
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Action/Redirect:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              {l7Policy.action}
              {actionRedirect(l7Policy.action).map( (redirect, index) =>
                <span className="display-flex" key={index}>
                  <div>{redirect.label}: </div>
                  {redirect.value === "redirect_prefix" || redirect.value === "redirect_url" ?
                    <CopyPastePopover text={l7Policy[redirect.value]} shouldPopover={false} bsClass="cp label-right"/>
                  :
                  <span className="label-right">{l7Policy[redirect.value]}</span>              
                  }
                </span>
              )}
            </div>
          </div>
        </div>

        <div className="multiple-subtable-entry">
          <div className="row">
            <div className="col-md-12">
              <b>Rules:</b>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              {l7Policy.rules.length}
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  );
}
 
export default L7PolicySelected;