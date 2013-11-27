// Generated by CoffeeScript 1.6.3
var CozyProxy, displayRoutes, router, _base;

CozyProxy = require('./proxy').CozyProxy;

if ((_base = process.env).NODE_ENV == null) {
  _base.NODE_ENV = "development";
}

process.on('uncaughtException', function(err) {
  console.error(err.message);
  return console.error(err.stack);
});

displayRoutes = function(error) {
  var route, _results;
  if (error) {
    console.log(error.message);
    return console.log("Routes initializing failed");
  } else {
    console.log("Routes initialized");
    _results = [];
    for (route in router.routes) {
      _results.push(console.log("" + route + " => " + router.routes[route]));
    }
    return _results;
  }
};

if (!module.parent) {
  router = new CozyProxy();
  router.start();
  console.log("Proxy listen on port " + router.proxyPort);
  console.log("Initializing routes...");
  router.resetRoutes(displayRoutes);
}
