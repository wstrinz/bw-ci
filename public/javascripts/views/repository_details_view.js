RepositoryDetailView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<h1>Repository</h1> ' +
                               '<h3>Name</h3>' +
                               '<p>{{name}}</p>' +
                               '<h3>Owner</h3> ' +
                               '<p>{{owner}}</p>'),
  tagName: 'div',
  className: 'repositoryDetail',
})
