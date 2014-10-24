/*

*/

module.exports = function() {
    return {
        /*
            This is used by the
        */
        getCacheItem: function() {
            return {
                title: this.title,
                createdBy: this.createdBy,
                createdAt: this.createdAt,
                updatedAt: this.updatedAt
            };
        }
    };
};
