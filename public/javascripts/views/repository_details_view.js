RepositoryDetailView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<h1>Repository</h1><p>{{name}}</p>'),
  tagName: 'div',
  className: 'repositoryDetail',
})
