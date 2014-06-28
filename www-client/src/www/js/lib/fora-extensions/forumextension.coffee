class ForumExtension

    constructor: (@typeDefinition, @loader) ->


    getTemplateModule: (name) =>*
        return require "/js/extensions/#{@typeDefinition.name}/templates/#{name}"
        yield false

module.exports = ForumExtension
