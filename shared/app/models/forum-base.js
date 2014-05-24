// Generated by CoffeeScript 1.6.3
(function() {
  var ForaDbModel, ForaModel, ForumBase,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ForaModel = require('./foramodel').ForaModel;

  ForaDbModel = require('./foramodel').ForaDbModel;

  ForumBase = (function(_super) {
    var Settings, Stats, Summary;

    __extends(ForumBase, _super);

    function ForumBase() {
      return ForumBase.__super__.constructor.apply(this, arguments);
    }

    Settings = (function(_super1) {
      __extends(Settings, _super1);

      function Settings() {
        return Settings.__super__.constructor.apply(this, arguments);
      }

      Settings.typeDefinition = {
        name: "forum-settings",
        schema: {
          type: 'object',
          properties: {
            commentsEnabled: {
              type: 'boolean'
            },
            commentsOpened: {
              type: 'boolean'
            }
          }
        }
      };

      return Settings;

    })(ForaModel);

    ForumBase.Settings = Settings;

    Summary = (function(_super1) {
      __extends(Summary, _super1);

      function Summary() {
        return Summary.__super__.constructor.apply(this, arguments);
      }

      Summary.typeDefinition = {
        name: "forum-summary",
        schema: {
          type: 'object',
          properties: {
            id: {
              type: 'string'
            },
            network: {
              type: 'string'
            },
            name: {
              type: 'string'
            },
            stub: {
              type: 'string'
            },
            createdBy: {
              $ref: "user-summary"
            }
          },
          required: ['id', 'network', 'name', 'stub', 'createdBy']
        }
      };

      return Summary;

    })(ForaModel);

    ForumBase.Summary = Summary;

    Stats = (function(_super1) {
      __extends(Stats, _super1);

      function Stats() {
        return Stats.__super__.constructor.apply(this, arguments);
      }

      Stats.typeDefinition = {
        name: "forum-stats",
        schema: {
          type: 'object',
          properties: {
            posts: {
              type: 'number'
            },
            members: {
              type: 'number'
            },
            lastPost: {
              type: 'number'
            }
          },
          required: ['posts', 'members', 'lastPost']
        }
      };

      return Stats;

    })(ForaModel);

    ForumBase.Stats = Stats;

    ForumBase.childModels = {
      Stats: Stats,
      Summary: Summary,
      Settings: Settings
    };

    ForumBase.typeDefinition = function() {
      return {
        name: 'forum',
        collection: 'forums',
        discriminator: function*(obj) {
          var def;
          def = yield Forum.getTypeUtils().getTypeDefinition(obj.type);
          if (def.ctor !== Forum) {
            throw new Error("Forum type definitions must have ctor set to Forum");
          }
          return def;
        },
        schema: {
          type: 'object',
          properties: {
            type: {
              type: 'string'
            },
            network: {
              type: 'string'
            },
            name: {
              type: 'string'
            },
            description: {
              type: 'string'
            },
            stub: {
              type: 'string'
            },
            access: {
              type: 'string',
              "enum": ['public', 'protected', 'private']
            },
            createdById: {
              type: 'string'
            },
            createdBy: {
              $ref: 'user-summary'
            },
            settings: {
              $ref: 'forum-settings'
            },
            cover: {
              $ref: 'cover'
            },
            theme: {
              type: 'string'
            },
            cache: {
              type: 'object',
              properties: {
                posts: {
                  type: 'array',
                  items: {
                    type: 'object',
                    properties: {
                      image: {
                        type: 'string'
                      },
                      title: {
                        type: 'string'
                      },
                      createdBy: {
                        $ref: 'user-summary'
                      },
                      id: {
                        type: 'string'
                      },
                      stub: {
                        type: 'string'
                      }
                    },
                    required: ['title', 'createdBy', 'id', 'stub']
                  }
                }
              },
              required: ['posts']
            },
            stats: {
              $ref: 'forum-stats'
            }
          },
          required: ['type', 'network', 'name', 'description', 'stub', 'access', 'createdById', 'createdBy', 'cache', 'stats']
        },
        indexes: [
          {
            'createdById': 1,
            'network': 1
          }, {
            'stub': 1,
            'network': 1
          }
        ],
        autoGenerated: {
          createdAt: {
            event: 'created'
          },
          updatedAt: {
            event: 'updated'
          }
        },
        links: {
          createdBy: {
            type: 'user-summary',
            key: 'createdById'
          },
          posts: {
            type: 'post',
            field: 'forumId'
          },
          info: {
            type: 'forum-info',
            field: 'forumId'
          }
        },
        logging: {
          onInsert: 'NEW_FORUM'
        }
      };
    };

    return ForumBase;

  })(ForaDbModel);

  module.exports = ForumBase;

}).call(this);
