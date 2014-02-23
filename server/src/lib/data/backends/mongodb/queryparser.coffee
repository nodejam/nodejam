###
    MongoDb parser really doesn't need to do much, because we use a subset of the same query syntax.
    1. Make sure queries use only supported operators
    2. We do not support comparing fields with complex type. eg (of invalid): { company: { name: 'fora', location: 'india' } }
    
    TODO: Warn when queries are not operating on indexes, but checking typeDefinitions
###

class MongoDbQueryParser

    constructor: (@typeDefinitions) ->
        
    

    parse: (node = {}, typeDefinition) =>
        @visit_NODE node, {}, []
        node

    
    
    visit_NODE: (node, current, parents) =>
        #eg: value(ie, RHS) in { name: 'jeswin' }
        if node is null or ['string', 'number', 'boolean'].indexOf(typeof node) > -1 
            return

        #eg: value(ie, RHS) in { $or: [ {obj1}, {obj2} ] } 
        else if node instanceof Array                    
            for item in node
                @visit_NODE item, current, parents
            return

        #eg 1: { name: { $or: [ {obj1}, {obj2} ] } 
        #eg 2: { age: { $lt: 20 } }
        else
            parents.push current
            for k, v of node            
                (if k[0] isnt "$" then @visit_FIELD else @visit_OPERATOR) k, node, parents
            parents.pop()
            return
            

    ###
        The value part of a field can be
        A value; eg: { username: 'jeswin' }
    ###
    
    visit_FIELD: (k, current, parents) =>
        @visit_NODE current[k], current, parents
        
    
    
    ###
        http://docs.mongodb.org/manual/reference/operator/query/
        
        Comparison operators will not require further parsing, since the value is always a simple type.
        eg: { $gte: 10 }, we don't need to anything with this.
    
        --------------------------------------------------------
        $gt     Matches values that are greater than the value specified in the query.
        $gte	Matches values that are equal to or greater than the value specified in the query.
        $in     Matches any of the values that exist in an array specified in the query.
        $lt     Matches values that are less than the value specified in the query.
        $lte	Matches values that are less than or equal to the value specified in the query.
        $ne	    Matches all values that are not equal to the value specified in the query.
        $nin	Matches values that do not exist in an array specified to the query.        
        
        Logical operators need to be parsed further
        
        -------------------------------------------
        $or	    Joins query clauses with a logical OR returns all documents that match the conditions of either clause.
        $and	Joins query clauses with a logical AND returns all documents that match the conditions of both clauses.
        $not	Inverts the effect of a query expression and returns documents that do not match the query expression.
        $nor	Joins query clauses with a logical NOR returns all documents that fail to match both clauses.                
    ###
    
    visit_OPERATOR: (k, current, parents) =>
        #Is a comparison operator? Nothing to do then.
        if ['$gt', '$gte', '$lt', '$lte', '$ne', '$in', '$nin'].indexOf(k) > -1
            return
        else if ['$or', '$and', '$not', '$nor'].indexOf(k) > -1
            @visit_NODE current[k], current, parents
        else
            throw new Error "Unknown operator #{k}"
       
        

module.exports = MongoDbQueryParser
