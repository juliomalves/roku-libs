'********************************************************************
'**  request.brs
'**  
'**  Julio Alves, April 2016
'********************************************************************
'**  Examples:
'**  req = Request({url: "https://www.apiserver.com/content/0001", headers: reqHeaders, filePath: "tmp:/data.json"})
'**  req.setTimeout(20000)
'**  req.send()
'**   
'**  req = Request({url: "http://www.apiserver.com/content/0001", headers: reqHeaders, method: "DELETE"})
'**  req.setTimeout(10000).setRetries(3)
'**  req.send() 
'**  
'**  req = Request({url: "http://www.apiserver.com/login", headers: reqHeaders, method: "POST"})
'**  req.send(reqData)
'********************************************************************
   
function Request(reqObj as Object) as Object
    obj = {
        _timeout: 10000 'Call timeout
        _interval: 500 'Interval between retry calls
        _retries: 1 'Number of call retries
        _deviceInfo: createObject("roDeviceInfo")
        
        _httpEncode: function(str as String) as String
            return createObject("roUrlTransfer").escape(str)
        end function

        _http: invalid

        _createHttpRequest: function(reqObj as Object) as Object
            urlTransfer = createObject("roUrlTransfer")
            urlTransfer.setPort(createObject("roMessagePort"))
            urlTransfer.setUrl(reqObj.url)
            urlTransfer.retainBodyOnError(true)
            urlTransfer.enableCookies()

            if reqObj.method <> invalid then urlTransfer.setRequest(reqObj.method)
            if reqObj.headers <> invalid then urlTransfer.setHeaders(reqObj.headers)
            
            'Checks if URL is secured, and adds appropriate parameters if needed
            if left(reqObj.url, 5) = "https" then
                urlTransfer.setCertificatesFile("common:/certs/ca-bundle.crt")
                urlTransfer.addHeader("X-Roku-Reserved-Dev-Id", "")
                urlTransfer.initClientCertificates()
            end if
            
            return urlTransfer
        end function

        _reqObj: reqObj

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

        getPort: function()
            return m._http.getPort()
        end function

        getCookies: function(domain as String, path as String) as Object
            return m._http.getCookies(domain, path)
        end function

        send: function(data=invalid as Dynamic) as Dynamic
            timeout = m._timeout
            retries = m._retries
            msg = invalid

            if data <> invalid and getInterface(data, "ifString") = invalid then
                data = formatJson(data)
            end if

            while retries > 0
                if not m._deviceInfo.getLinkStatus() then return msg
                
                if m._sendHttpRequest(data) then
                    event = m._http.getPort().waitMessage(timeout)

                    if type(event) = "roUrlEvent" then
                        msg = event 
                        if event.getResponseCode() >= 200 and event.getResponseCode() < 300 then exit while 
                    end if

                    m._http.asyncCancel()
                    timeout = timeout * 2
                    sleep(m._interval)
                end if

                retries--
            end while
            
            return msg
        end function

        _sendHttpRequest: function(data=invalid as Dynamic) as Dynamic
            m._http = m._createHttpRequest(m._reqObj)

            if lCase(m._http.getRequest()) = "post" or data <> invalid then
                if m._reqObj.filePath <> invalid then
                    return m._http.asyncPostFromFile(m._reqObj.filePath)
                else
                    return m._http.asyncPostFromString(data)
                end if
            else
                if m._reqObj.filePath <> invalid then
                    return m._http.asyncGetToFile(m._reqObj.filePath)
                else
                    return m._http.asyncGetToString()
                end if
            end if
        end function

    }    

    return obj
end function
