'----------------------------------------------------------------
' MockServer helper functions
'----------------------------------------------------------------

function Helper__CreateMockServer(hostName as String, port as Integer) as Object
    server = createObject("roStreamSocket")
    server.setMessagePort(createObject("roMessagePort"))
    address = createObject("roSocketAddress")
    address.setHostName(hostName)
    address.setPort(port)
    server.setAddress(address)
    server.notifyReadable(true)
    server.listen(1)
    return server
end function

' Respond with HTTP 200 OK, and return request data
function Helper__HandleMockServerEvent(server as Object) as Object
    buffer = createObject("roByteArray")
    buffer[1024] = 0
    request = {}
    msg = server.getMessagePort().waitMessage(1000)
    if type(msg) = "roSocketEvent" then
        if msg.getSocketID() = server.getID() and server.isReadable() then
            connection = server.accept()
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