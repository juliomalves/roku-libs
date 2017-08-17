'
'   Roku Analytics Tracking Library 2.0 - google-analytics.brs
'   (Adapted from Roku Univesal Analytics Tracking Library
'   https://github.com/thyngster/roku-universal-analytics)
'
'   Julio Alves, March 2017
'
'   Examples:
'   Tracker init
'   GA_Tracker().init("UA-12345678-90")
'
'   Event tracking
'   GA_Tracker().trackEvent({ category: "application", action: "launch"})
'
'   Screen tracking
'   GA_Tracker().trackScreen({ name: "mainScreen" })
'
'   E-Commerce tracking
'   GA_Tracker().trackTransaction({ id: "OD564", revenue: "10.00"})
'   GA_Tracker().trackItem({ transactionId: "OD564", name: "Test01", price: "10.00", code: "TEST001", category: "vod"})
'

function GoogleAnalyticsLib() as Object

    if m.analytics = invalid then

        getDeviceVersion = function() as String
            version = createObject("roDeviceInfo").getVersion()

            major = mid(version, 3, 1)
            minor = mid(version, 5, 2)
            build = mid(version, 9, 4)

            return major + "." + minor + "." + build
        end function

        ai = createObject("roAppInfo")
        di = createObject("roDeviceInfo")

        m.analytics = {
            _trackingID: invalid
            _clientID: di.getClientTrackingId()
            _deviceModel: di.getModel()
            _deviceVersion: getDeviceVersion()
            _appName: ai.getTitle()
            _appVersion: ai.getVersion()
            _ratio: di.getDisplayAspectRatio()
            _display: di.getUIResolution().width.toStr() + "x" + di.getUIResolution().height.toStr()
            _endpoint: "http://www.google-analytics.com/collect"'"https://ssl.google-analytics.com/collect"
            _protocol: "1"
            _isTracking: false
            _port: createObject("roMessagePort")
            _url: invalid

            init: function(trackingId as String)
                m._trackingID = trackingId
                m._isTracking = true
            end function

            getPort: function()
                return m._port
            end function

            getBaseObject: function
                return {
                    v: m._protocol
                    cid: m._clientID
                    tid: m._trackingID
                }
            end function

            trackEvent: function(event as Object) as Dynamic
                if not m._isTracking then return invalid

                payload = getBaseObject()
                payload.append({
                    sr : m._display
                    vp : m._ratio
                    an : m._appName
                    av : m._appVersion
                    ds : "app"
                    t  : "event"
                    ec : event.category
                    ea : event.action
                    el : event.label
                    ev : event.value
                    cd1 : event.dim1
                })

                return m._send(payload)
            end function

            trackScreen: function(screen as Object) as Dynamic
                if not m._isTracking then return invalid

                payload = getBaseObject()
                payload.append({
                    sr : m._display
                    vp : m._ratio
                    an : m._appName
                    av : m._appVersion
                    ds : "app"
                    t  : "screenview"
                    cd : screen.name
                })
                
                return m._send(payload)
            end function

            trackTransaction: function(transaction as Object) as Dynamic
                if not m._isTracking then return invalid

                payload = getBaseObject()
                payload.append({
                    ds : "app"
                    t  : "transaction"
                    ta : "roku"
                    ti : transaction.id
                    tr : transaction.revenue
                    tt : transaction.tax
                    cu : transaction.currencyCode
                    cd1 : transaction.dim1
                })

                return m._send(payload)
            end function

            trackItem: function(item as Object) as Dynamic
                if not m._isTracking then return invalid

                payload = getBaseObject()
                payload.append({
                    ds : "app"
                    t  : "item"
                    iq : item.quantity
                    ti : item.transactionId
                    in : item.name
                    ip : item.price
                    cu : item.currencyCode
                    ic : item.code
                    iv : item.category
                })

                return m._send(payload)
            end function

            _send: function(payload as Object) as Object
                m._url = m._createPayloadUrl(payload)

                req = createObject("roURLTransfer")
                req.setMessagePort(m._port)
                req.setUrl(m._url)
                req.asyncGetToString()

                return req
            end function

            _createPayloadUrl: function(params as Object) as String
                payload = "?"
                for each key in params
                    value = params[key]
                    if value <> invalid then
                        payload = payload + key + "=" + m._httpEncode(value) + "&"
                    end if
                end for
                payload = payload + "z=" + rnd(500).toStr()

                return m._endpoint + payload
            end function

            _httpEncode: function(str as String) as String
                return createObject("roUrlTransfer").escape(str)
            end function

            handleResponse: function(msg)
                if type(msg) = "roUrlEvent" then
                    if msg.getResponseCode() >= 200 and msg.getResponseCode() < 300 then
                        print "[GA-lib] Tracking successful: "; m._url
                    else
                        print "[GA-lib] Tracking failed: "; m._url
                    end if
                end if
            end function

        }
    end if

    return m.analytics
end function
