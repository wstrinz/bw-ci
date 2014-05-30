RepositoriesView = Backbone.Marionette.CompositeView.extend({
  itemView: RepositoryView,
  template: _.template('<div class="repositories"></div>'),

  appendHtml: function(collectionView, itemView){
    collectionView.$('.repositories').append(itemView.el);
  },

});
