/* eslint-disable */
window.JXBCallBackList = {};

window.JXBJSBridge = {
call:call,
};

String.prototype.hashCode = function() {
    var hash = 0;
    if (this.length == 0) return hash;
    for (var index = 0; index < this.length; index++) {
        var charactor = this.charCodeAt(index);
        hash = ((hash << 5) - hash) + charactor;
        hash = hash & hash;
    }
    return hash;
};



window.Callback = function(identifier, resultStatus, resultData) {
    
    callBackDict = window.JXBCallBackList[identifier];
    
    if (callBackDict) {
        
        isFinished = true;
        if (resultStatus == "success") {
            callBackDict.success(resultData);
        }
        if (resultStatus == "fail") {
            callBackDict.fail(resultData);
        }
        if (resultStatus == "progress") {
            isFinished = false;
            callBackDict.progress(resultData);
        }
        
        if (isFinished) {
            window.JXBCallBackList[identifier] = null;
            delete window.JXBCallBackList[identifier];
        }
    }
}


function call(bridgeObjc) {
    var dataString = encodeURIComponent(JSON.stringify(bridgeObjc.data));
    var timestamp = Date.parse(new Date());
    var identifier = (bridgeObjc.target + bridgeObjc.action + dataString + timestamp).hashCode().toString();
    window.JXBCallBackList[identifier] = bridgeObjc.callback;
    window.webkit.messageHandlers.WKNativeMethodMessage.postMessage({
                                                                    targetName:bridgeObjc.target,
                                                                    actionName:bridgeObjc.action,
                                                                    data:bridgeObjc.data,
                                                                    identifier:identifier,
                                                                    });
}

var JSCallBackMethodManager = {
    removeAllCallBacks: function(data){
        window.JXBCallBackList = {};
    }
};
