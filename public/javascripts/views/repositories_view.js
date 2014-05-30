RepositoriesView = Backbone.Marionette.CollectionView.extend({
  className: 'jumbotron',
  itemView: RepositoryView,
  template: _.template('<div class="repositories"></div>'),
  tagName: 'ul',

  appendHtml: function(collectionView, itemView){
    collectionView.$el.append(itemView.el);
  },

});
