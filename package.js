Package.describe({
  summary: 'Simple client-side routing'
});



Package.on_use(function (api) {
  api.use(['coffeescript', 'http']);
  api.use(['templating'], 'client');
  api.use(['css-stylus', 'ctrl', 'util']);
  api.export('Router');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('client/ctrl/current-route.html', 'client');
  api.add_files('client/ns.js', 'client');
  api.add_files('client/router.coffee', 'client');
  api.add_files('client/ctrl/current-route.coffee', 'client');
  api.add_files('client/libs/page-js.js', 'client');
  api.add_files('client/page.coffee', 'client');
  api.add_files('client/route-context.coffee', 'client');
  api.add_files('client/route-model-factory.coffee', 'client');
  api.add_files('client/route-reactor.coffee', 'client');

});


