JobView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<h1>Job</h1><p>{{job_name}}</p>')
})
