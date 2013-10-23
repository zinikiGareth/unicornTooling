var http = require('http');

http.createServer(function(req, resp) {
  var msg = "";
  var name = req.headers["x-module-name"];
  req.on('data', function(chunk) {
    msg += chunk
  });
  req.on('end', function() {
    console.log("  Compiling template " + name);
    var handlebars = require('ember-templates');
   //  var singleton = handlebars.Handlebars;
    // var local = handlebars.create();
    var foo = handlebars.precompile(msg);

    var output = "define('" + name + "', [],  function() { return Ember.Handlebars.template( " + foo + "); });";
    resp.writeHead(200, {'Content-Type': 'application/javascript' });
    resp.end(output);
  });
}).listen(10062);
