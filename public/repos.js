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
  if(repo.jobName) {
    $.get("/job_config/" + repo.jobName, function(data){
      updateConfigDisplay(repo, data)
      $("#repo" + repo.id).find(".save-changes").text("Update Job")
    })
  }
  div = $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  div.css("display","inline-block")

}

function disableRepo(repo){
  div = $("#onoffswitch-" + repo.id).parent().parent().children(".repo-config-box")
  $("#onoffswitch-" + repo.id).prop("checked", false)
  div.hide()
}

function updateConfigDisplay(repo, config){
  $("#repo" + repo.id).find(".build-script").text(config.build_script)
  $("#repo" + repo.id).find(".enable-pullrequest").prop("checked", config.enable_pullrequests)
}

function retrieveBuildScript(repo){
  refresh_button = $("#repo" + repo.id).find(".refresh-build-script")
  $.get('/test_config/'+ repo.owner + '/' + repo.name, function(data){
    if(data.type == "none"){
      refresh_button.text("No Build Script Found")
    }
    else {
      refresh_button.text("Found build script for: " + data.type)
      if(data.config.script){
        $("#repo" + repo.id).find(".build-script").text(data.config.script)
      }
    }
  })
}

function retrieveBuildScriptClick(el){
  repo_node = el.parentNode.parentNode.parentNode ;
  id = parseInt(repo_node.id.substring(4, repo_node.id.length)) ;
  repo = repos[id] ;

  retrieveBuildScript(repo)
}

function saveJob(repo){
  id = repo.id
  job_name      = repo.jobName ? repo.jobName : repo.name
  github_repo   = repo.owner + "/" + repo.name
  enable_pr     = $("#repo" + id).find(".enable-pullrequest").prop("checked")
  build_script  = $("#repo" + id).find(".build-script").val()

  data = {
    job_name:             job_name,
    enable_pullrequests:  enable_pr,
    github_repo:          github_repo,
    build_script:         build_script
  }

  $.post("/enable_job", {data: JSON.stringify(data)}, function(data){
    if(data.status == "success"){
      syncWithJenkins()
    }
    else {
      alert("failed")
      console.log(data.reason)
    }
  })
}

function saveJobClick(el){
  repo_node = el.parentNode.parentNode.parentNode ;
  id = parseInt(repo_node.id.substring(4, repo_node.id.length)) ;
  repo = repos[id] ;

  saveJob(repo)
}

function deleteJob(repo){
  $.post("/delete_job/" + repo.jobName, {}, function(data){
    if(data.status == "success"){
      $("#repo" + repo.id).find(".save-changes").text("Create Job")
      disableRepo(repo)
      syncWithJenkins()
    }
    else {
      alert("delete failed")
      console.log(data.reason)
    }
  })
}

function deleteJobClick(el){
  repo_node = el.parentNode.parentNode.parentNode ;
  id = parseInt(repo_node.id.substring(4, repo_node.id.length)) ;
  repo = repos[id] ;

  deleteJob(repo)
}

function configHtml(){
  return '<div class="repo-config-box"> \
            <div class="repo-config"> \
              <input type="checkbox" class="enable-pullrequest"> \
              Enable Pull Request builds? \
              <br/> \
              <textarea class="build-script" cols="50" rows="15"></textarea> \
              <br/> \
              <button type="button" class="refresh-build-script" onclick=retrieveBuildScriptClick(this)>Get Build Script From Repository</button> \
              <br/> \
              <button type="button" class="save-changes" onclick=saveJobClick(this)>Create Job</button> \
              <button type="button" class="delete-job" disabled onclick=deleteJobClick(this)>Delete Job</button> \
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

function syncWithJenkins(){
  $.get("/enabled_repositories", function(data) {

    _.each(repos, function(r){
      jenkins_repo = _.findWhere(data, {url: r.url})
      if(jenkins_repo){
        r.jobName = jenkins_repo.job_name
        $("#repo" + r.id).find(".save-changes").text("Update Job")
        $("#repo" + r.id).find(".delete-job").prop("disabled", false)
        if(!$("#onoffswitch-" + r.id).prop("checked"))
          $("#onoffswitch-" + r.id).trigger("click")
      }
      else{
      }
    })
  })
}

function getRepos(){
  $.get("/repositories", function(data){
    $("#repo-list").html('')
    _.each(data, function(d){
      addRepo(d)
    })

    syncWithJenkins()
  })
}

$(document).ready( function(){
  getRepos();
} )
