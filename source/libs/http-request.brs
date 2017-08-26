'********************************************************************
'**  http-request.brs
'********************************************************************
'**  Examples:
'**  req = HttpRequest()
'**  req.open("https://www.apiserver.com/content/0001").setTimeout(20000)
'**  req.send()
'**   
'**  req = HttpRequest()
'**  req.open("http://www.apiserver.com/content/0001", "DELETE")
'**  req.setTimeout(10000).setRetries(3)
'**  req.send() 
'**  
'**  req = HttpRequest()
'**  req.open("http://www.apiserver.com/login", "POST")
'**  req.setRequestHeaders({"Content-Type": "application/json"})
'**  req.send({user: "johndoe", password: "12345"})
'**  req.abort()
'********************************************************************
   
function HttpRequest() as Object
    obj = {
        _timeout: 0
        _interval: 500
        _retries: 1
        _deviceInfo: createObject("roDeviceInfo")
        _url: invalid
        _method: invalid
        _requestHeaders: {}
        _http: invalid
        _isAborted: false

        _isUrlSecure: function(url as String) as Boolean
            return left(url, 5) = "https"
        end function

        _createHttpRequest: function() as Object
            request = createObject("roUrlTransfer")
            request.setPort(createObject("roMessagePort"))
            request.setUrl(m._url)
            request.retainBodyOnError(true)
            request.enableCookies()
            request.setHeaders(m._requestHeaders)
            if m._method <> invalid then request.setRequest(m._method)
            
            'Checks if URL is secured, and adds appropriate parameters if needed
            if m._isUrlSecure(m._url) then
                request.setCertificatesFile("common:/certs/ca-bundle.crt")
                request.addHeader("X-Roku-Reserved-Dev-Id", "")
                request.initClientCertificates()
            end if
            
            return request
        end function

        setTimeout: function(value as Integer)
            m._timeout = value
            return m
        end function

        setInterval: function(value as Integer)
            m._interval = value
            return m
        end function

        setRetries: function(value as Integer)
            m._retries = value
            return m
        end function
        
        setRequestHeaders: function(headers as Object)
            m._requestHeaders = headers
            return m
        end function

        getPort: function()
            if m._http <> invalid then
                return m._http.getPort()
            else 
                return invalid
            end if
        end function

        getCookies: function(domain as String, path as String) as Object
            if m._http <> invalid then
                return m._http.getCookies(domain, path)
            else 
                return invalid
            end if
        end function

        open: function(url as String, method=invalid as Dynamic)
            m._url = url
            m._method = method
        end function

        send: function(data=invalid as Dynamic) as Dynamic
            timeout = m._timeout
            retries = m._retries
            response = invalid

            if data <> invalid and getInterface(data, "ifString") = invalid then
                data = formatJson(data)
            end if
            
            while retries > 0
                if not m._deviceInfo.getLinkStatus() then return response
                
                if m._sendHttpRequest(data) then
                    event = m._http.getPort().waitMessage(timeout)

                    if m._isAborted then 
                        m._isAborted = false
                        m._http.asyncCancel()
                        exit while
                    else if type(event) = "roUrlEvent" then
                        response = event 
                        exit while
                    end if

                    m._http.asyncCancel()
                    timeout = timeout * 2
                    sleep(m._interval)
                end if

                retries--
            end while
            
            return response
        end function

        _sendHttpRequest: function(data=invalid as Dynamic) as Dynamic
            m._http = m._createHttpRequest()
            
            if data <> invalid then
                return m._http.asyncPostFromString(data)
            else
                return m._http.asyncGetToString()
            end if
        end function

        abort: function()
            m._isAborted = true
        end function

    }    

    return obj
end function
