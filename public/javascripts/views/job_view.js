JobView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<h1>Job</h1>' +
                               '<form name="input" action="job/{{job_name}}">' +
                                  '<div>' +
                                    '<label for="job_name">Job Name</h3>' +
                                  '</div>' +
                                  '<div>' +
                                    '<input type="text" id="job_name" name="job_name" value="{{job_name}}"/>' +
                                  '</div>' +
                                  '<div>' +
                                    '<label for="github_repo">Github Repo</h3>' +
                                  '</div>' +
                                  '<div>' +
                                    '<input type="text" disabled="disabled" id="github_repo" name="github_repo" value="{{github_repo}}"/>' +
                                  '</div>' +
                                  '<div>' +
                                    '<label for="build_script">Build Script</h3>' +
                                  '</div>' +
                                  '<div>' +
                                    '<textarea rows=8 cols=60 id="build_script" name="build_script">{{build_script}}</textarea>' +
                                  '</div>' +
                               '</form>')
})
