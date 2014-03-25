var repos = []

function toggleRepo(repoId){
  index = parseInt(repoId)
  repo = repos[index]
  state = $("#onoffswitch-" + repoId).is(":checked")
  if(state){
    enableRepo(repo)
  }
  else{
    disableRepo(repo)
  }
  console.log("toggle " + repo.name + " (id " + index + ") to " + state)
}

function enableRepo(repo){
  div = $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  console.log(div)
  div.css("display","inline-block")
}

function disableRepo(repo){
  $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  .hide()
}

function confirmDisable(repo){
}

function configHtml(){
  return '<div class="repo-config-box"> \
            <div class="repo-config"> \
              <input type="checkbox" class="enable-pullrequest"> \
              Enable Pull Request builds? \
              <br/> \
              <textarea class="build-script" cols="50" rows="15"></textarea> \
              <br/> \
              <button class="retrieve-build-script">Get Build Script From Repository</button> \
              <br/> \
              <button class="save-changes">Save</button> \
            </div> \
          </div>'
}
function switchHtml(id, name){
  return name + '<div class="repo"> \
    <div class="onoffswitch"> \
      <input type="checkbox" id="onoffswitch-' + id + '" onclick=toggleRepo(' + id + ') name="onoffswitch" class="onoffswitch-checkbox"> \
      <label class="onoffswitch-label" for="onoffswitch-' + id + '"> \
          <div class="onoffswitch-inner"></div> \
          <div class="onoffswitch-switch"></div> \
      </label> \
    </div>' + configHtml() + ' \
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
