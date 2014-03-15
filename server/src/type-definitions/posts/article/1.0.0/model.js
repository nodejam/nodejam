module.exports = function(require) {
    return {
        /* 
            save: Gives you a hook to make changes to the post before it gets saved.
        */
        save: function*() {
            //If no cover was specified, use 'inline-cover'
            if (this.cover && !this.cover.type) {
                this.cover.type = "inline-cover";
            }    
        },
        
        /* 
            view: return a view of the object based on name.
            A view is a subset (or summary) of fields in the post.
        */
        view: function*(name) {
            return {
                image: this.cover ? this.cover.image.small : null,
                title: this.title,
                createdBy: this.createdBy,
                id: this._id.toString(),
                stub: this.stub
            }
        }        
    }
}
