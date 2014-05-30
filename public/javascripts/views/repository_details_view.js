RepositoryDetailView = Backbone.Marionette.ItemView.extend({
  template: _.template('<h1>Repository!</h1><p><%= name %></p>'),
  tagName: 'div',
  className: 'repositoryDetail',
})
