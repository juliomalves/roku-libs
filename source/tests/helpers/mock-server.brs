'----------------------------------------------------------------
' MockServer helper
'----------------------------------------------------------------

function MockServer() as Object
    obj = {
        streamSocket: invalid

        create: function(hostName as String, port as Integer)
            m.streamSocket = createObject("roStreamSocket")
            m.streamSocket.setMessagePort(createObject("roMessagePort"))
            address = createObject("roSocketAddress")
            address.setHostName(hostName)
            address.setPort(port)
            m.streamSocket.setAddress(address)
            m.streamSocket.notifyReadable(true)
            m.streamSocket.listen(1)
        end function

        destroy: function()
            m.streamSocket.close()
            m.streamSocket = invalid
        end function

        ' Respond with HTTP 200 OK, and return request data
       handleEvent: function() as Dynamic
            if m.streamSocket = invalid then return invalid
            buffer = createObject("roByteArray")
            buffer[1024] = 0
            request = {}
            msg = m.streamSocket.getMessagePort().waitMessage(1000)
            if type(msg) = "roSocketEvent" then
                if msg.getSocketID() = m.streamSocket.getID() and m.streamSocket.isReadable() then
                    connection = m.streamSocket.accept()
                    received = connection.receive(buffer, 0, 1024)
                    ' Send an HTTP 200 response
                    connection.send("HTTP/1.1 200 OK" + chr(13) + chr(10) + chr(13) + chr(10), 0, 19)
                    connection.close()
                    ' Parse request
                    request.code = 200
                    regex = createObject("roRegex", "(?<=\s)\s.*", "s")
                    requestBody = regex.match(buffer.toAsciiString())
                    if requestBody.count() > 0 then request.data = requestBody[0].trim()
                end if
            end if
            return request
        end function
    }

    return obj
end function



