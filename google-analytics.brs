'
'   Roku Analytics Tracking Library 2.0 - google-analytics.brs
'   (Adapted from Roku Univesal Analytics Tracking Library
'   https://github.com/thyngster/roku-universal-analytics)
'
'   Julio Alves, March 2017
'
'   Examples:
'   Tracker init
'   GA_Tracker().setTrackingID("UA-12345678-90")
'
'   Event tracking
'   GA_Tracker().trackEvent({ category: "application", action: "launch"})
'
'   Screen tracking
'   GA_Tracker().trackScreen({ name: "mainScreen" })
'
'   Transaction tracking
'   GA_Tracker().trackTransaction({ transID: "OD564", transRevenue: "10.00"})
'   GA_Tracker().trackItem({ transID: "OD564", itemName: "Test01", itemPrice: "10.00", itemCode: "TEST001", itemCat: "vod"})
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
            _accountID: invalid
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

            setTrackingID: function(trackingId as String)
                m._accountID = trackingId
                m._isTracking = true
            end function

            getPort: function()
                return m._port
            end function

            trackEvent: function(event as Object) as Dynamic
                if not m._isTracking then return invalid

                return m._sendData({
                    v  : m._protocol
                    cid: m._clientID
                    tid: m._accountID
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
            end function

            trackScreen: function(screen as Object) as Dynamic
                if not m._isTracking then return invalid

                return m._sendData({
                    v  : m._protocol
                    cid: m._clientID
                    tid: m._accountID
                    sr : m._display
                    vp : m._ratio
                    an : m._appName
                    av : m._appVersion
                    ds : "app"
                    t  : "screenview"
                    cd : screen.name
                })
            end function

            trackTransaction: function(transaction as Object) as Dynamic
                if not m._isTracking then return invalid

                return m._sendData({
                    v  : m._protocol
                    cid: m._clientID
                    tid: m._accountID
                    ds : "app"
                    t  : "transaction"
                    ta : "Roku"
                    ti : transaction.transID
                    tr : transaction.transRevenue
                    tt : transaction.transTax
                    cu : transaction.curCode
                    cd1 : transaction.dim1
                })
            end function

            trackItem: function(item as Object) as Dynamic
                if not m._isTracking then return invalid

                return m._sendData({
                    v  : m._protocol
                    cid: m._clientID
                    tid: m._accountID
                    ds : "app"
                    t  : "item"
                    iq : "1"
                    ti : item.transID
                    in : item.itemName
                    ip : item.itemPrice
                    cu : item.curCode
                    ic : item.itemCode
                    iv : item.itemCat
                })
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

            _sendData: function(payload as Object) as Object
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

        }
    end if

    return m.analytics
end function
