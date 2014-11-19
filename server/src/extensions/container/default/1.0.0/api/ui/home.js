(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        DbConnector = require('fora-app-db-connector'),
        Parser = require('fora-request-parser');

    var typesService = services.getTypesService();

    var index = function*() {
        var cacheItemStore = new DbConnector(models.CacheItem);

        var cacheItem = yield* cacheItemStore.findOne({ type: 'cache', key: 'home' });

        var makeRecords = function*(cacheItems) {
            var results = [];
            for (var i = 0; i < cacheItems.length; i++) {
                results.push({
                    record: yield* models.Record.new(cacheItems[i].record),
                    app: cacheItems[i].app
                });
            }
            return results;
        };

        var editorsPicks = yield* makeRecords(cacheItem.value.editorsPicks);
        var featured = yield* makeRecords(cacheItem.value.featured);

        var cover = {
            image: { src: '/images/cover.jpg' },
        };

        var coverContent = "<h1>Editor's Picks</h1>\
            <p>Fora is a place to share ideas. Lorem Ipsum Bacon?</p>";

        this.body = { editorsPicks: editorsPicks, featured: featured, cover: cover, coverContent: coverContent };
    };


    var actions = function*() {
        var parser = new Parser(this, typesService);

        var items = (yield* parser.body("type")).split(',');
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            switch(item) {
                case "refresh-cache":
                    _ = yield* refreshHome.call(this);
            }
        }
    };


    var refreshHome = function*() {
        var db = services.getDb();

        var recordStore = new DbConnector(models.Record);

        var editorsPicks = yield* recordStore.find({ meta: 'pick' }, { sort: db.setRowId({}, -1), limit: 1 });

        //Featured must not included editor's Picks.
        var featured = yield* recordStore.find({ meta: 'featured' }, { sort: db.setRowId({}, -1), limit: 12 });
        featured = featured.filter(function(fi) {
            return editorsPicks.map(function(ei) { return DbConnector.getRowId(ei); }).indexOf(DbConnector.getRowId(fi)) === -1;
        });

        var cacheItemStore = new DbConnector(models.CacheItem);

        //Delete all existing
        var existingCacheItems = yield* cacheItemStore.find({ type: 'cache', key: 'home' });
        for (var i = 0; i < existingCacheItems.length; i++) {
            _ = yield* existingCacheItems[i].destroy();
        }

        //Add a new one.
        //We much cache the app summary as well.
        var appStore = new DbConnector(models.App);
        var makeCacheItem = function*(records) {
            var results = [];
            for (var i = 0; i < records.length; i++) {
                var app = yield* appStore.findById(records[i].appId);
                results.push({ record: records[i], app: app.summarize() });
            }
            return results;
        };

        var cacheItem = new models.CacheItem({
            type: 'cache',
            key: 'home',
            value: { featured: yield* makeCacheItem(editorsPicks), editorsPicks: yield* makeCacheItem(featured) },
        });
        _ = yield* cacheItem.save();

        this.body = "OK";
    };


    module.exports = {
        index: index,
        actions: actions
    };

})();
