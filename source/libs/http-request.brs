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
'**  req = HttpRequest({
'**      url: "http://www.apiserver.com/login",
'**      method: "POST",
'**      headers: { "Content-Type": "application/json" },
'**      data: { user: "johndoe", password: "12345" }
'**  })
'**  req.send()
'********************************************************************
   
function HttpRequest(params=invalid as Dynamic) as Object
    url = invalid
    method = invalid
    headers = {}
    data = invalid

    if params <> invalid then
        if params.url <> invalid then url = params.url
        if params.method <> invalid then method = params.method
        if params.headers <> invalid then headers = params.headers
        if params.data <> invalid then data = params.data
    end if

    obj = {
        _timeout: 0
        _interval: 500
        _retries: 1
        _deviceInfo: createObject("roDeviceInfo")
        _url: url
        _method: method
        _requestHeaders: headers
        _data: data
        _http: invalid
        _isAborted: false

        _isProtocolSecure: function(url as String) as Boolean
            return left(url, 6) = "https:"
        end function

        _createHttpRequest: function() as Object
            request = createObject("roUrlTransfer")
            request.setPort(createObject("roMessagePort"))
            request.setUrl(m._url)
            request.retainBodyOnError(true)
            request.enableCookies()
            request.setHeaders(m._requestHeaders)
            if m._method <> invalid then request.setRequest(m._method)
            
            'Checks if URL protocol is secured, and adds appropriate parameters if needed
            if m._isProtocolSecure(m._url) then
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
            return m
        end function

        send: function(data=invalid as Dynamic) as Dynamic
            timeout = m._timeout
            retries = m._retries
            response = invalid

            if data <> invalid then m._data = data

             if m._data <> invalid and getInterface(m._data, "ifString") = invalid then
                m._data = formatJson(m._data)
            end if
            
            while retries > 0 and m._deviceInfo.getLinkStatus()
                if m._sendHttpRequest(m._data) then
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
                    timeout *= 2
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
