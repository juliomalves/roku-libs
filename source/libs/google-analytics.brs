'
'   Roku Analytics Tracking Library 2.0 - google-analytics.brs
'   (Adapted from Roku Univesal Analytics Tracking Library
'   https://github.com/thyngster/roku-universal-analytics)
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
            _endpoint: "https://www.google-analytics.com/collect"
            _protocol: "1"
            _payload: invalid
            _enabled: false
            _port: createObject("roMessagePort")
            _sentRequests: {}

            init: function(trackingId as String)
                m._trackingID = trackingId
                m._enabled = true
            end function

            getPort: function() as Object
                return m._port
            end function

            _getBaseObject: function() as Object
                return {
                    v: m._protocol
                    cid: m._clientID
                    tid: m._trackingID
                }
            end function

            trackEvent: function(event as Object) as Dynamic
                if not m._enabled then return invalid

                payload = m._getBaseObject()
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
                if not m._enabled then return invalid

                payload = m._getBaseObject()
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
                if not m._enabled then return invalid

                payload = m._getBaseObject()
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
                if not m._enabled then return invalid

                payload = m._getBaseObject()
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

            _send: function(payload as Object)
                m._payload = m._encodePayload(payload)

                req = createObject("roURLTransfer")
                req.setMessagePort(m._port)
                req.setUrl(m._endpoint)
                req.setRequest("POST")
                req.setCertificatesFile("common:/certs/ca-bundle.crt")
                req.addHeader("X-Roku-Reserved-Dev-Id", "")
                req.initClientCertificates()
                req.asyncPostFromString(m._payload)

                m._sentRequests[req.getIdentity().toStr()] = req

                msg = req.getPort().waitMessage(0)
                m._handleResponse(msg)
            end function

            _encodePayload: function(params as Object) as String
                payload = ""
                for each key in params
                    value = params[key]
                    if value <> invalid then
                        payload = payload + key + "=" + m._encodeUri(value) + "&"
                    end if
                end for
                payload = payload + "z=" + rnd(500).toStr()

                return payload
            end function

            _encodeUri: function(str as String) as String
                return createObject("roUrlTransfer").escape(str)
            end function

            _handleResponse: function(msg)
                if type(msg) = "roUrlEvent" then
                    sourceIdentity = msg.getSourceIdentity().toStr()
                    if m._sentRequests[sourceIdentity] <> invalid then
                        print "[GA-lib] Response: "; msg.getResponseCode(); " "; msg.getFailureReason(); " @ "; m._endpoint + "?" + m._payload
                        m._sentRequests.delete(sourceIdentity)
                    end if
                end if
            end function

        }
    end if

    return m.analytics
end function
