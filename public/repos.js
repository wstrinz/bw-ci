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
}

function enableRepo(repo){
  div = $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  div.css("display","inline-block")
}

function disableRepo(repo){
  div = $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  div.hide()
}

function confirmDisable(repo){
}

function retrieveBuildScript(el){
  $(el).text("Loading...")
  repo_node = el.parentNode.parentNode.parentNode ;
  id = parseInt(repo_node.id.substring(4, repo_node.id.length)) ;
  repo = repos[id] ;
  $.get('/test_config/'+ repo.owner + '/' + repo.name, function(data){
    if(data.type == "none"){
      $(el).text("No Build Script Found")
    }
    else {
      console.log(data)
      $(el).text("Found build script for: " + data.type)
      if(data.config.script){
        $(el).parent().find(".build-script").text(data.config.script)
      }
    }
  })
}

function configHtml(){
  return '<div class="repo-config-box"> \
            <div class="repo-config"> \
              <input type="checkbox" class="enable-pullrequest"> \
              Enable Pull Request builds? \
              <br/> \
              <textarea class="build-script" cols="50" rows="15"></textarea> \
              <br/> \
              <button type="button" class="retrieve-build-script" onclick=retrieveBuildScript(this)>Get Build Script From Repository</button> \
              <br/> \
              <button type="button" class="save-changes">Save</button> \
            </div> \
          </div>'
}

function switchHtml(id, name){
  return name + '<div class="repo" id="repo' + id + '"> \
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
      _.each(data, function(d){ enabled_repos.push(d.url) })

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
