JobView = Backbone.Marionette.ItemView.extend({
  template: _.template('<h1>Job</h1><p><%= job_name %></p>')
})
