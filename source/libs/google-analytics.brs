'
'   Roku Analytics Tracking Library 2.0 - google-analytics.brs
'   (Adapted from Roku Univesal Analytics Tracking Library
'   https://github.com/thyngster/roku-universal-analytics)
'
'   Examples:
'   - Tracker init
'   googleAnalytics = GoogleAnalyticsLib()
'   googleAnalytics.init("UA-12345678-90")
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

function GoogleAnalyticsLib() as Object

    if m.analytics = invalid then

        ai = createObject("roAppInfo")
        di = createObject("roDeviceInfo")

        m.analytics = {
            _baseParams: {
                v: "1",
                cid: di.getClientTrackingId(),
                an : ai.getTitle(),
                av : ai.getVersion()
            }
            _endpoint: "https://www.google-analytics.com/collect"
            _payload: invalid
            _enabled: false
            _sequence: 1
            _port: createObject("roMessagePort")
            _sentRequests: {}

            init: function(trackingId as String)
                m._baseParams["tid"] = trackingId
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
                    ds : "app"
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
                    ds : "app"
                    t  : "screenview"
                    cd : screen.name
                }
                
                return m._send(payload)
            end function

            trackTransaction: function(transaction as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    ds : "app"
                    t  : "transaction"
                    ta : "roku"
                    ti : transaction.id
                    tr : transaction.revenue
                    tt : transaction.tax
                    cu : transaction.currencyCode
                    cd1 : transaction.dim1
                }

                return m._send(payload)
            end function

            trackItem: function(item as Object) as Dynamic
                if not m._enabled then return invalid

                payload = {
                    ds : "app"
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

            _send: function(payload as Object)
                payload.append(m._baseParams)
                m._payload = m._encodePayload(payload)
                
                req = createObject("roURLTransfer")
                req.setMessagePort(m._port)
                req.setUrl(m._endpoint)
                req.setRequest("POST")
                req.setCertificatesFile("common:/certs/ca-bundle.crt")
                req.initClientCertificates()
                req.addHeader("X-Roku-Reserved-Dev-Id", "")
                req.addHeader("Content-Type", "text/plain")
                req.asyncPostFromString(m._payload)

                m._sentRequests[req.getIdentity().toStr()] = req

                m._cleanupRequests()
            end function

            _encodePayload: function(params as Object) as String
                payload = ""
                for each key in params
                    value = params[key]
                    if value <> invalid then
                        payload = payload + key + "=" + m._encodeUri(value) + "&"
                    end if
                end for
                payload = payload + "z=" + m._sequence.toStr()'rnd(500).toStr()
                m._sequence++
                return payload
            end function

            _encodeUri: function(str as String) as String
                return createObject("roUrlTransfer").escape(str)
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
