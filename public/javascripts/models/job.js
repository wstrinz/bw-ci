Job = Backbone.Model.extend({
  parse: function(attributes){
    var re = /git@github\.com:([^\/]*)\/(.*)\.git/;
    var matches = re.exec(attributes.github_repo);

    if(matches)
      attributes.github_repo = matches[1] + '/' + matches[2];

    return attributes;
  }
})
