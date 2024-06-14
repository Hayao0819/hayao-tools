// // @ts-check

// /**
//  *
//  *
//  * @param {(i : object)=> void} func
//  */
// const runFuncOnTabChanged = (func) => chrome.tabs.onActivated.addListener;

// const getCurrent = async () =>
//   await chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
//     const tab = tabs[0];
//     console.log(tab.url);
//   });

// runFuncOnTabChanged(() => getCurrent());
