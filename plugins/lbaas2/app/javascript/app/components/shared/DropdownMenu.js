import React, { useState, useEffect } from "react"
import { DropdownButton, MenuItem } from 'react-bootstrap'
import uniqueId from 'lodash/uniqueId'

const DropDownMenu = ({ name }) => {
  const [componentID, setcomponentID] = useState(null)

  // $('.dropdown').on('show.bs.dropdown', function () {
  //   $('body').append($('.dropdown').css({
  //     position:'absolute',
  //     left:$('.dropdown').offset().left, 
  //     top:$('.dropdown').offset().top
  //   }).detach());
  // });
  
  // $('.dropdown').on('hidden.bs.dropdown', function () {
  //   $('.bs-example').append($('.dropdown').css({
  //     position:false, left:false, top:false
  //   }).detach());
  // });


  useEffect(() => {
    if (componentID) {
      const $element = $("#"+componentID)
      console.log($element)

      var $table = $element.closest('.table-responsive'),
          $menu = $element.find('.dropdown-menu')

      if ($table) {
        // console.group("metrics")
        // console.log($table)
        // console.log($menu)
        // console.groupEnd()

        $element.on('show.bs.dropdown', function () {
          console.log("testing")
          var tableOffsetHeight = $table.offset().top + $table.height(),
              menuOffsetHeight = $element.offset().top + $element.outerHeight(true) + $menu.outerHeight(true)

          // console.group("metrics")
          // console.log($element)
          // console.log($table)
          // console.log($menu)
          // console.log("table offset top: ", $table.offset().top)
          // console.log("table height: ", $table.height())
          // console.log("element offset top: ", $element.offset().top)
          // console.log("element height: ", $element.outerHeight(true))
          // console.log("menu offset top: ", $menu.offset().top)
          // console.log("menu height: ", $menu.outerHeight(true))
          // console.log(tableOffsetHeight)
          // console.log(menuOffsetHeight)
          // console.log(menuOffsetHeight > tableOffsetHeight)
          // console.log(menuOffsetHeight - tableOffsetHeight)
          // console.log("scrolltop: ", $table.scrollTop())
          // console.groupEnd()

          if (menuOffsetHeight > tableOffsetHeight) {
            var padding = menuOffsetHeight - tableOffsetHeight
            var scrollTarget = $table.scrollTop() + padding
            console.group("metrics")
            console.log("padding: ", padding)
            console.log("scrollTarget", scrollTarget)
            console.groupEnd()
            $table.css("padding-bottom", padding)
            // $table.scrollTop(scrollTarget)
            $table.animate({
              scrollTop: scrollTarget
              }, 1000)
          }
        });
        
        $element.on('hide.bs.dropdown', function () {
          $table.css("padding-bottom", 0);
        })
      }

      // element.on('show.bs.dropdown', function () {
      //   console.log("test")
      //   $('body').append(element.css({
      //     position:'absolute',
      //     left:element.offset().left, 
      //     top:element.offset().top
      //   }).detach());
      // });
      
      // element.on('hidden.bs.dropdown', function () {
      //   $('.bs-example').append(element.css({
      //     position:false, left:false, top:false
      //   }).detach());
      // });



      // $('.table-responsive').on('shown.bs.dropdown', function (e) {
      //   var $table = $(this),
      //       $menu = $(e.target).find('.dropdown-menu'),
      //       tableOffsetHeight = $table.offset().top + $table.height(),
      //       menuOffsetHeight = $menu.offset().top + $menu.outerHeight(true);
    
      //   console.group("metrics")
      //   console.log($table)
      //   console.log($menu)
      //   console.log(tableOffsetHeight)
      //   console.log(menuOffsetHeight)
      //   console.log(menuOffsetHeight - tableOffsetHeight)
      //   console.groupEnd()

      //   if (menuOffsetHeight > tableOffsetHeight)
      //     $table.css("padding-bottom", menuOffsetHeight - tableOffsetHeight);
      // });
    
      // $('.table-responsive').on('hide.bs.dropdown', function () {
      //   $(this).css("padding-bottom", 0);
      // })

    }
  }, [componentID]);

  useEffect(() => {
    const cpID = uniqueId("drop-down-menu")
    setcomponentID(cpID)
  }, [])

  return (
    <React.Fragment>
      <div className="btn-group custom-dropdown" id={componentID} >
        <button
          className="btn btn-default btn-sm dropdown-toggle"
          type="button"
          data-toggle="dropdown"
          aria-expanded={true}
        >
          test
        </button>
        <ul className="dropdown-menu dropdown-menu-right" role="menu">
            <li>
              Test1
            </li>
            <li>
              Test2
            </li>
            <li>
              Test3
            </li>
          </ul>
      </div>
    </React.Fragment>
  )
}

export default DropDownMenu