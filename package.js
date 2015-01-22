Package.describe({
  name: 'respondly:router-client',
  summary: 'Simple client-side routing',
  version: '1.0.2',
  git: 'https://github.com/Respondly/meteor-router-client.git'
});



Package.onUse(function (api) {
  // api.versionsFrom('1.0');
  api.use(['coffeescript', 'http']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use('respondly:css-stylus@1.0.3');
  api.use('respondly:ctrl@1.0.1');
  api.use('respondly:util@1.0.1');
  api.export('Router');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.addFiles('client/ctrl/current-route.html', 'client');
  api.addFiles('client/ns.js', 'client');
  api.addFiles('client/router.coffee', 'client');
  api.addFiles('client/ctrl/current-route.coffee', 'client');
  api.addFiles('client/libs/page-js.js', 'client');
  api.addFiles('client/page.coffee', 'client');
  api.addFiles('client/route-context.coffee', 'client');
  api.addFiles('client/route-model-factory.coffee', 'client');
  api.addFiles('client/route-reactor.coffee', 'client');

});

Package.onTest(function(api){
  api.use(['mike:mocha-package@0.4.7', 'coffeescript']);

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.addFiles('tests/shared/sample.coffee', ['client', 'server']);
});
