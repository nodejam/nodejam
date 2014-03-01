exports.getView = function(name) {
    return {
        image: this.cover ? this.cover.image.small : null,
        title: this.title,
        createdBy: this.createdBy,
        id: this._id.toString(),
        stub: this.stub
    }
}
