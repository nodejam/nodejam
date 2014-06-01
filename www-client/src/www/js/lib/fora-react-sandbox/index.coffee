class React

    init: ->
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
                    


module.exports = React
