format = (since) ->    
    delta = Math.round((+new Date - since) / 1000)

    minute = 60
    hour = minute * 60
    day = hour * 24
    week = day * 7
    
    if (delta < 30) 
        fuzzy = 'just then.'
    else if (delta < minute) 
        fuzzy = delta + ' seconds ago.'
    else if (delta < 2 * minute) 
        fuzzy = 'a minute ago.'
    else if (delta < hour) 
        fuzzy = Math.floor(delta / minute) + ' minutes ago.'
    else if (Math.floor(delta / hour) == 1) 
        fuzzy = '1 hour ago.'
    else if (delta < day) 
        fuzzy = Math.floor(delta / hour) + ' hours ago.'
    else if (delta < day * 2) 
        fuzzy = 'yesterday'    
    else if (delta < 30 * day)
        fuzzy = Math.floor(delta/day) + ' days ago.'
    else
        fuzzy = 'A month back.'
        
    return fuzzy

exports.format = format

