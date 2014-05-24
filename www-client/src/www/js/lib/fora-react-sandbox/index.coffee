
class ReactSandbox

    constructor: ->
        $ =>
                
            elements = $(document).find("[data-reactjs-sandbox-event]")
            
            if elements
                
                for e in elements
                    e = $(e)
                    events = e.data('reactjs-sandbox-event').split(',')
                    for ev in events
                        switch ev
                            when 'click'
                                e.click ->                         
                
                window.addEventListener 'message', (e) ->
                    if e.data is 'LOAD'
                        iFrame.contentWindow.postMessage('a = 10;', '*');
                        
                iFrame = @createIFrame()
            
                
            
    createIFrame: ->
        iFrame = $ "
            <iFrame sandbox=\"allow-scripts\" 
                srcdoc=\"
                    <script>
                        window.addEventListener('message', function(e) {
                            eval(e.data);
                            parent.postMessage('done!', '*');
                        });

                        window.onload = function() {
                            parent.postMessage('LOAD', '*');
                        }
                    </script>
                    This is a sandbox.
                \">
            </iFrame>"
        $('body').append iFrame
        return iFrame[0]
        
module.exports = ReactSandbox
