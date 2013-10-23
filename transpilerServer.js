var http = require('http');

http.createServer(function(req, resp) {
  var msg = "";
  var name = req.headers["x-module-name"];
  req.on('data', function(chunk) {
    msg += chunk
  });
  req.on('end', function() {
    console.log("  Transpiling module " + name);
//    console.log(msg);
    var Compiler = require("es6-module-transpiler").Compiler;
    var compiler = new Compiler(msg, name);
    var output = compiler.toAMD();
    resp.writeHead(200, {'Content-Type': 'application/javascript' });
    resp.end(output);
  });
}).listen(10061);
