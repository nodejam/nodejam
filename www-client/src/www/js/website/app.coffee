co = require('co');

class App

    initPage: (pageName, props) =>
        document.addEventListener 'DOMContentLoaded', ->
            setupPage = ->*
                reactClass = require(pageName);
                props = JSON.parse(props);
                component = reactClass(props);
                if component.componentInit
                    yield component.componentInit()
            co(setupPage)()
            
window.app = new App();

module.exports = App
