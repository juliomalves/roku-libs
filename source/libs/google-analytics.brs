'
'   Roku Analytics Tracking Library 2.0 - google-analytics.brs
'   (Adapted from Roku Univesal Analytics Tracking Library
'   https://github.com/thyngster/roku-universal-analytics)
'
'   Examples:
'   - Tracker init
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.init("UA-12345678-90")
'   OR with multiple tracking ids
'   googleAnalytics.init(["UA-12345678-90", ..., "UA-09876543-21"])
'
'   - Event tracking
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.trackEvent({ category: "application", action: "launch"})
'
'   - Screen tracking
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.trackScreen({ name: "mainScreen" })
'
'   - E-Commerce tracking
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.trackTransaction({ id: "OD564", revenue: "10.00"})
'   googleAnalytics.trackItem({ transactionId: "OD564", name: "Test01", price: "10.00", code: "TEST001", category: "vod"})
'
'   - Timing tracking
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.trackTiming({ category: "category", variable: "timing", time: "1000" })
'
'   - Exception tracking
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.trackException({ description: "description", isFatal: "1" })
'

function GoogleAnalyticsLib() as Object

    if m.analytics = invalid then

        ai = createObject("roAppInfo")
        di = createObject("roDeviceInfo")

        m.analytics = {
            _baseParams: {
                v: "1",
                cid: di.getChannelClientId(),
                an : ai.getTitle(),
                av : ai.getVersion(),
                ds : "app"
            }
            _trackingId: invalid
            _endpoint: "https://www.google-analytics.com/collect"
            _endpointBatch: "https://www.google-analytics.com/batch"
            _enabled: false
            _sequence: 1
            _port: createObject("roMessagePort")
            _sentRequests: {}

            init: function(trackingId as Dynamic)
                m._trackingId = trackingId ' Either a string or an array of strings
                m._enabled = true
            end function

            setParams: function(customParams as Object)
                m._baseParams.append(customParams)
            end function

            getPort: function() as Object
                return m._port
            end function

            trackEvent: function(event as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t  : "event"
                    ec : event.category
                    ea : event.action
                    el : event.label
                    ev : event.value
                    cd1 : event.dim1
                }

                return m._send(payload)
            end function

            trackScreen: function(screen as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t  : "screenview"
                    cd : screen.name
                }
                
                return m._send(payload)
            end function

            trackTransaction: function(transaction as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t  : "transaction"
                    ta : transaction.affiliation
                    ti : transaction.id
                    tr : transaction.revenue
                    tt : transaction.tax
                    ts : transaction.shipping
                    cu : transaction.currencyCode
                }

                return m._send(payload)
            end function

            trackItem: function(item as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t  : "item"
                    iq : item.quantity
                    ti : item.transactionId
                    in : item.name
                    ip : item.price
                    cu : item.currencyCode
                    ic : item.code
                    iv : item.category
                }

                return m._send(payload)
            end function

            trackTiming: function(timing as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t : "timing"
                    utc : timing.category
                    utv : timing.variable
                    utt : timing.time
                    plt : timing.loadTime
                    srt : timing.responseTime
                }
                
                return m._send(payload)
            end function

            trackException: function(exception as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    t : "exception"
                    exd : exception.description
                    exf : exception.isFatal
                }
                
                return m._send(payload)
            end function
            

            _send: function(payload as Object)
                payload.append(m._baseParams)
                encodedPayload = m._encodePayload(payload)
                data = m._createPostData(encodedPayload)
                
                req = createObject("roURLTransfer")
                req.setMessagePort(m._port)
                req.setUrl(data.endpoint)
                req.setRequest("POST")
                req.setCertificatesFile("common:/certs/ca-bundle.crt")
                req.initClientCertificates()
                req.addHeader("X-Roku-Reserved-Dev-Id", "")
                req.addHeader("Content-Type", "text/plain")
                req.asyncPostFromString(data.body)

                m._sentRequests[req.getIdentity().toStr()] = req

                m._cleanupRequests()
            end function

            _encodePayload: function(params as Object) as String
                payload = ""
                for each item in params.items()
                    if item.value <> invalid then
                        payload = payload + item.key + "=" + m._encodeUri(item.value) + "&"
                    end if
                end for
                payload = payload + "z=" + m._sequence.toStr()'rnd(500).toStr()
                m._sequence++
                return payload
            end function

            _encodeUri: function(str as String) as String
                return createObject("roUrlTransfer").escape(str)
            end function

            _createPostData: function(payload as String) as Object
                body = ""
                if getInterface(m._trackingId, "ifString") = invalid then
                    endpoint = m._endpointBatch
                    for each id in m._trackingId
                        body += "tid=" + m._encodeUri(id) + "&" + payload + chr(10)
                    end for
                    body = body.left(body.len()-1)
                else
                    endpoint = m._endpoint
                    body = "tid=" + m._encodeUri(m._trackingId) + "&" + payload
                end if
                return { endpoint: endpoint, body: body }
            end function

            _cleanupRequests: function()
                for each request in m._sentRequests
                    msg = m._port.getMessage()
                    if type(msg) = "roUrlEvent" then
                        requestId = msg.getSourceIdentity().toStr()
                        if msg.getInt() = 1 then m._sentRequests.delete(requestId)
                    end if
                end for
            end function

        }
    end if

    return m.analytics
end function
