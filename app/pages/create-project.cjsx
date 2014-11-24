React = require 'react'
Model = require '../lib/model'
InPlaceForm = require '../components/in-place-form'
MarkdownEditor = require '../components/markdown-editor'
projects = require '../api/projects'
alert = require '../lib/alert'

languages = ['en-us']

newProjectData = new Model
  name: ''
  introduction: ''
  description: ''
  science_case: ''
  primary_language: languages[0]

module.exports = React.createClass
  displayName: 'CreateProjectPage'

  componentDidMount: ->
    newProjectData.listen @handleProjectChange

  componentWillUnmount: ->
    newProjectData.stopListening @handleProjectChange

  handleProjectChange: ->
    @forceUpdate()

  render: ->
    <div className="create-project-page">
      <div className="content-container">
        <h1>Create a new project</h1>
        <h2>General information</h2>
        <p>Name: <input type="text" name="display_name" placeholder="Project name" value={newProjectData.display_name} onChange={@handleInputChange} /></p>
        <p>Introduction: <input type="text" name="introduction" placeholder="A catchy slogan for the project" value={newProjectData.introduction} onChange={@handleInputChange} /></p>
        <p>TODO: Avatar</p>

        <hr />

        <h2>Describe your project</h2>
        <p><MarkdownEditor name="description" placeholder="Why is this project interesting?" value={newProjectData.description} onChange={@handleInputChange} /></p>
        <hr />

        <h2>Explain your science case</h2>
        <p><MarkdownEditor name="science_case" placeholder="A more detailed explanation of what you hope to acheive with the data you collect" value={newProjectData.science_case} onChange={@handleInputChange} /></p>

        <hr />

        <h2>Upload some example images</h2>
        <p>TODO</p>
        <p>You’ll be able to pick multiple files in the file picker:</p>
        <input type="file" multiple="multiple" name="example_images" onChange={@handleInputChange} disabled="disabled" />
        <ul>
          {<li key={file.name}>{file.name}</li> for file in newProjectData.example_images ? []}
        </ul>

        <hr />

        <h2>Define the classification workflow</h2>
        <p>TODO</p>

        <hr />

        <h2>Review and complete</h2>
        <table>
          <tr>
            <td>{<i className="fa fa-check"></i> if newProjectData.name}</td>
            <td>Name</td>
          </tr>
          <tr>
            <td>{<i className="fa fa-check"></i> if newProjectData.description}</td>
            <td>Description</td>
          </tr>
          <tr>
            <td>{<i className="fa fa-check"></i> if newProjectData.science_case}</td>
            <td>Science case</td>
          </tr>
          <tr>
            <td>{<i className="fa fa-check"></i> if newProjectData.example_images?.length isnt 0}</td>
            <td>Example images</td>
          </tr>
        </table>

        <button type="submit" onClick={@handleSubmit}>Create</button>
      </div>
    </div>

  handleInputChange: (e) ->
    valueProperty = switch e.target.type
      when 'radio', 'checkbox' then 'checked'
      when 'file' then 'files'
      else 'value'

    changes = {}
    changes[e.target.name] = e.target[valueProperty]

    newProjectData.update changes

  handleSubmit: ->
    data = JSON.parse JSON.stringify newProjectData # Clear out functions, etc.
    projects.createResource(data).save()
      .then (project) ->
        location.hash = '/build/edit-project/' + project.id

      .catch (errors) ->
        alert <p>Error saving project: <code>{errors}</code></p>
