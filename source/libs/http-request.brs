'********************************************************************
'**  http-request.brs
'********************************************************************
'**  Examples:
'**  req = HttpRequest("https://www.apiserver.com/content/0001")
'**  req.setTimeout(20000)
'**  req.send()
'**   
'**  req = HttpRequest("http://www.apiserver.com/content/0001", "DELETE")
'**  req.setTimeout(10000).setRetries(3)
'**  req.send() 
'**  
'**  req = HttpRequest("http://www.apiserver.com/login", "POST")
'**  req.setRequestHeaders({"Content-Type": "application/json"})
'**  req.send({user: "johndoe", password: "12345"})
'**  req.abort()
'********************************************************************
   
function HttpRequest(url as String, method=invalid as Dynamic) as Object
    obj = {
        _timeout: 0
        _interval: 500
        _retries: 1
        _deviceInfo: createObject("roDeviceInfo")
        _url: url
        _method: method
        _requestHeaders: {}
        _http: invalid
        _isAborted: false

        _isUrlSecure: function(url as String) as Boolean
            return left(url, 5) = "https"
        end function

        _createHttpRequest: function() as Object
            urlTransfer = createObject("roUrlTransfer")
            urlTransfer.setPort(createObject("roMessagePort"))
            urlTransfer.setUrl(m._url)
            urlTransfer.retainBodyOnError(true)
            urlTransfer.enableCookies()
            urlTransfer.setHeaders(m._requestHeaders)
            if m._method <> invalid then urlTransfer.setRequest(m._method)
            
            'Checks if URL is secured, and adds appropriate parameters if needed
            if m._isUrlSecure(m._url) then
                urlTransfer.setCertificatesFile("common:/certs/ca-bundle.crt")
                urlTransfer.addHeader("X-Roku-Reserved-Dev-Id", "")
                urlTransfer.initClientCertificates()
            end if
            
            return urlTransfer
        end function

        setTimeout: function(value as Integer)
            _timeout = value
            return m
        end function

        setInterval: function(value as Integer)
            _interval = value
            return m
        end function

        setRetries: function(value as Integer)
            _retries = value
            return m
        end function
        
        setRequestHeaders: function(headers as Object)
            m._requestHeaders = headers
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

        send: function(data=invalid as Dynamic) as Dynamic
            timeout = m._timeout
            response = invalid

            if data <> invalid and getInterface(data, "ifString") = invalid then
                data = formatJson(data)
            end if

            while m._retries > 0
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
