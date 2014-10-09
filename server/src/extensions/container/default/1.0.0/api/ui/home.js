(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services');

    var index = function*() {
        var db = services.get('db');

        var editorsPicks = yield* models.Record.find({ meta: 'pick' },{ sort: db.setRowId({}, -1) , limit: 1 });

        var featured = yield* models.Record.find({ meta: 'featured' }, { sort: db.setRowId({}, -1) , limit: 12 });

        //Featured must not included editor's Picks.
        featured = featured.filter(function(fi) {
            return editorsPicks.map(function(ei) { return ei.getRowId(); }).indexOf(fi.getRowId()) === -1;
        });

        var cover = {
            image: { src: '/images/cover.jpg' },
        };

        var coverContent = "<h1>Editor's Picks</h1>\
            <p>Fora is a place to share ideas. Lorem Ipsum Bacon?</p>";

        this.body = { editorsPicks: editorsPicks, featured: featured, cover: cover, coverContent: coverContent };
    };

    module.exports = { index: index };

})();
