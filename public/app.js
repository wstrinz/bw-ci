var App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.Router.map(function(){
  this.route('repos');
})

App.IndexController = Ember.Controller.extend({
  message: "hurlo"
});
