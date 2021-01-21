var Action = function() {};

Action.prototype = {

run: function(parameters) {
    // Called before the extension is run.
    parameters.completionFunction({"URL": document.URL, "title": document.title});
},

finalize: function(parameters) {
    // Called after the extension is run.
}

};

var ExtensionPreprocessingJS = new Action
