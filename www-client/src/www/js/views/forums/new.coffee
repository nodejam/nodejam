class New extends window.Fora.Views.BaseView

    constructor: ->        
        $(document).ready =>
            me = this
            @setupEditor()
            
            
    
    setupEditor: =>
    
        typeDefinition = {
            schema: {
                properties: {
                    name: { type: 'string', maxLength: 50 }                        
                    description: { type: 'string', maxLength: 500 }                        
                },
                required: ['username', 'name']
            }
        }
        
        @editor = new ForaEditor typeDefinition, {}, "#create-forum-form"

        #name
        nameControl = @editor.addBinding 'name', { 
            element: '.name', 
            title: 'forum name', 
            placeholder: 'Type a forum name'
        }
        
        #about
        aboutControl = @editor.addBinding 'description', { 
            element: '.description', 
            title: 'description', 
            placeholder: 'Add a tagline....' 
        }     
        
        nameControl.focus()
        
        
window.Fora.Views.Forums.New = New
