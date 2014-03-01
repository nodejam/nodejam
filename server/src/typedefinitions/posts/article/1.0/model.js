exports.save = function*() {
    //By default, use inline cover.
    if (this.cover && !this.cover.type) {
        this.cover.type = "inline-cover";
    }    
}
    
    
exports.view = function*(name) {
    return {
        image: this.cover ? this.cover.image.small : null,
        title: this.title,
        createdBy: this.createdBy,
        id: this._id.toString(),
        stub: this.stub
    }
}
