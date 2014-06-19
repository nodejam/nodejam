(function() {
    "use strict";
    
    /* 
        typeDefinition: Defines the various fields in the type
    */
    exports.typeDefinition = {
        type: "forum",
        author: "Fora",
        schema: {
            type: "object",
            properties: {
                about: { type: "string", maxLength: 2000 },
                message: { type: "string", maxLength: 2000 }
            }
        }
    }
})();
