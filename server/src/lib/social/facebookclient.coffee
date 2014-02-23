###
    CREDITS:
    Code from https://github.com/DracoBlue/node-facebook-client
###

querystring = require 'querystring'
https = require 'https'

class FaceBookClient

    getOAuthCode: (req, secret) ->
    
        match = request_headers["cookie"].match(/fbsr_[\d]+\=([^; ]+)/)
        cookie = match[1]
        parts = cookie.split('.')
        
        buffer = new Buffer(convertBase64ToHex parts[0].replace(/\-/g, '+').replace(/\_/g, '/'), 'base64')
        signature = buffer.toString 'hex'
        
        payload = parts[1]
        json = new Buffer(payload.replace(/\-/g, '+').replace(/\_/g, '/'), 'base64').toString('binary')
        
        contents = JSON.parse json
        
        if not contents
            return
        
        #get the signature
        hmac = crypto.createHmac('sha256', secret)
        hmac.update(payload)
        expectedSignature = hmac.digest('hex')
            
        if not expectedSignature == signature
            return
            
        return contents['code'] 
      
  
    
    secureGraphRequest: (options, cb) ->

        options.host = 'graph.facebook.com'
        options.secure = true
        options.port = 443
        options.timeout = '15000'
        options.method = 'GET'
        
        req = https.request options, (res) ->
        
            res.setEncoding 'utf8'
                        
            result = ''            
            res.on 'data', (data) ->
                result += data
                
            res.on 'end', () ->
                cb null, result
                
            res.on 'error', (err) ->
                cb err, null
                
        req.end()
        
        
  
  
    getAccessToken: (code, clientId, clientSecret, cb) ->        
    
        options = {
            path: '/oauth/access_token?' + querystring.stringify({ code: code, client_id: clientId, redirect_uri: '', client_secret: clientSecret }),
        }
        
        @secureGraphRequest options, cb
        
    

            
    
module.exports = FaceBookClient
