RepositoriesView = Backbone.View.extend({
  initialize: function(){
    this.collection.on('add', this.addOne, this)
    this.collection.on('reset', this.render, this)
  },

  render: function(){
    this.addAll()
    return this;
  },

  addAll: function(){
    this.$el.empty();
    this.collection.forEach(this.addOne, this);
  },

  addOne: function(repository){
    var repoView = new RepositoryView({model: repository});
    this.$el.append(repoView.render().el);
  }
});
