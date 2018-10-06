var exec = require("cordova/exec");

exports.start = function(content) {
    exec(
        function(message) {
            console.log(message);
        },
        function(message) {
            console.log(message);
        },
        "tencentBgLocation",
        "start",
        [content]
    );
};

exports.stop = function() {
    exec(
        function(message) {
            console.log(message);
        },
        function(message) {
            console.log(message);
        },
        "tencentBgLocation",
        "stop",
        [{}]
    );
};
