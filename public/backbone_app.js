//CIApp = new Backbone.Marionette.Application();

var Repository = Backbone.Model.extend({
})

var Repositories = Backbone.Collection.extend({
  url: '/repositories',
  model: Repository,
})

var Job = Backbone.Model.extend({
})


var RepositoryView = Backbone.View.extend({
  template: _.template('<h3> I am a repository </h3> <p><%= name %></p>'),

  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
})

var RepositoriesView = Backbone.View.extend({
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

CIApp = new (Backbone.Router.extend({
  routes: {'': 'index'},

  initialize: function(){
    this.repositories = new Repositories();
    this.reposView = new RepositoriesView({collection: this.repositories});
    this.reposView.render()
  },

  start: function(){
    Backbone.history.start({pushState: true})
  },

  index: function(){
    console.log('in index')
    this.repositories.fetch({parse: true})
    $('#app').html(this.reposView.el)
  },

  show: function(id){
    //show repo
  }
}))

$(function(){ CIApp.start() })
