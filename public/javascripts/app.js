var libs = [
              'javascripts/lib/underscore/underscore.js',
              'javascripts/lib/jquery/dist/jquery.js',
              'javascripts/lib/json2/json2.js',
              'javascripts/lib/backbone/backbone.js',
              //'javascripts/lib/backbone.marionette.js',
              //'javascripts/lib/backbone.wreqr.js',
              //'javascripts/lib/backbone.babysitter.js',
              'javascripts/models/job.js',
              'javascripts/models/repository.js',
              'javascripts/models/repositories.js',
              'javascripts/views/repository_view.js',
              'javascripts/views/repositories_view.js',
              'javascripts/router.js',
           ]

require(libs, function (foo) {
  console.log('requires done')
  $(function(){ CIApp.start() })
});



