var repos = []

function toggleRepo(repoId){
  index = parseInt(repoId)
  repo = repos[index]
  state = $("#onoffswitch-" + repoId).is(":checked")
  if(state){
    showConfiguration(repo)
  }
  else{
    confirmDisable(repo)
  }
  alert("toggle " + repo.name + " (id " + index + ") to " + state)
}

function showConfiguration(repo){
}

function confirmDisable(repo){
}

function switchHtml(id, name){
  return name + '<div class="onoffswitch"> \
    <input type="checkbox" id="onoffswitch-' + id + '" onclick=toggleRepo(' + id + ') name="onoffswitch" class="onoffswitch-checkbox"> \
    <label class="onoffswitch-label" for="onoffswitch-' + id + '"> \
        <div class="onoffswitch-inner"></div> \
        <div class="onoffswitch-switch"></div> \
    </label> \
  </div>'
}

function addRepo(repo){
  var index = repos.length
  repo.id = index
  repos.push(repo)
  $("#repo-list").append(switchHtml(index, repo.name))
}

function getRepos(){
  $.get("/repositories", function(data){
    $("#repo-list").html('')
    _.each(data, function(d){
      addRepo(d)
    })

    enabled_repos = []
    $.get("/enabled_repositories", function(data) {
      _.each(data, function(d){ console.log(d.url); enabled_repos.push(d.url) })

      _.each(repos, function(r){
        if(_.contains(enabled_repos, r.url))
          $("#onoffswitch-" + r.id).trigger("click")
      })
    })
  })
}

$(document).ready( function(){
  getRepos();
} )
