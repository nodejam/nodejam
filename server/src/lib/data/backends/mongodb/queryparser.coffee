###
    MongoDb parser really doesn't need to do much, because we use a subset of the same query syntax.
    1. Make sure queries use only supported operators
    2. We do not support comparing fields with complex type. eg (of invalid): { company: { name: 'fora', location: 'india' } }
###

class MongoDbQueryParser

    constructor: (@typeDefinitions) ->
        
    
    
    parse: (node, current, parents) =>
        return node
        
        #eg: value(ie, RHS) in { name: 'jeswin' }
        if node is null or ['string', 'number', 'boolean'].indexOf(typeof v) > -1 
            node

        #eg: value(ie, RHS) in { $or: [ {obj1}, {obj2} ] } 
        else if node instanceof Array                    
            for item in node
                @parse item, current, parents

        #eg 1: { name: { $or: [ {obj1}, {obj2} ] } 
        #eg 2: { age: { $lt: 20 } }
        else 
            parents.push current
            for k, v of node            
                handler = switch k
                    when k[0] isnt "$"
                        @parse_FIELD
                    else
                        @parse_OPERATOR
                        
                handler k, node, parents
            parents.pop()
            
            

    ###
        The value part of a field can be
        A value; eg: { username: 'jeswin' }
    ###
    
    parse_FIELD: (k, param, root) =>
        param[k] = parse param[k]
        
    
    
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
    
    parse_OPERATOR: (k, param, root) =>
        #Is a comparison operator? Nothing to do then.
        if ['$gt', '$gte', '$lt', '$lte', '$ne', '$in', '$nin'].indexOf(k) > -1
            return
        else if ['$or', '$and', '$not', '$nor'].indexOf(k) > -1
            param[k] = parse param[k]
        else
            throw new Error "Unknown operator"
       
        

module.exports = MongoDbQueryParser
