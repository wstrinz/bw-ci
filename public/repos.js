var repos = []

function toggleRepo(repoId){
  index = parseInt(repoId)
  repo = repos[index]
  state = $("#onoffswitch-" + repoId).is(":checked")
  alert("toggle " + repo.name + " (id " + index + ") to " + state)
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
  repos.push(repo)
  $("#repo-list").append(switchHtml(index, repo.name))
}

function getRepos(){
  $.get("/repositories", function(data){
    $("#repo-list").html('')
    _.each(data, function(d){
      addRepo(d)
    })
  })
}

$(document).ready( function(){
  getRepos();
} )
