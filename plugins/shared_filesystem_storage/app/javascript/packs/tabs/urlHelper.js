const getCurrentTabFromUrl=function(){
  // check if tab uid is presented in url and update store if so.
  let currentTab = window.location.hash.match(/#[^&]+/);
  if (currentTab) {
    currentTab = currentTab[0].replace('#','');
  }
  return currentTab;
};

const setCurrentTabToUrl=function(uid){
  if (window.location.hash.length>0) {
    return window.location.hash = window.location.hash.replace(/#[^&]*/,uid);
  } else {
    return window.location.hash = uid;
  }
};

export { getCurrentTabFromUrl, setCurrentTabToUrl };
