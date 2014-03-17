module.exports = function(require) {
    return {
        save: function*() {
            //By default, use inline cover.
            if (this.cover && !this.cover.type) {
                this.cover.type = "inline-cover";
            }    
        },        
    }
}

