JobView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<h1>Job</h1>' +
                               '<h3>Job Name</h3>' +
                               '<p>{{job_name}}</p>' +
                               '<h3>Github Repo</h3>' +
                               '<p>{{github_repo}}</p>' +
                               '<h3>Build Script</h3>' +
                               '<p>{{build_script}}</p>' )
})
