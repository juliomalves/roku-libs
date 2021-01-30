'----------------------------------------------------------------
' HttpRequest Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__HttpRequest() as Object

    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "HTTP Request Library"

    this.SetUp = HttpRequestTestSuite__SetUp
    this.TearDown = HttpRequestTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("should create object with expected functions", TestCase__HttpRequest_Functions)
    this.addTest("can send a request", TestCase__HttpRequest_Send)
    this.addTest("can send a request with data", TestCase__HttpRequest_SendData)
    this.addTest("can send a request with passed parameters", TestCase__HttpRequest_SendParams)

    return this
end function

sub HttpRequestTestSuite__SetUp()
    m.testObject = HttpRequest()
    ' Mock server that will receive requests
    m.mockServer = MockServer()
    m.mockServer.create("127.0.0.1", 54321)
end sub

sub HttpRequestTestSuite__TearDown()
    m.mockServer.destroy()
    m.mockServer = invalid
    m.testObject = invalid
    m.delete("mockServer")
    m.delete("testObject")
end sub

function TestCase__HttpRequest_Functions()
    expectedFunctions = [
        "send",
        "abort",
        "getPort",
        "getCookies"
    ]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__HttpRequest_Send()
    m.testObject = HttpRequest({
        url: "http://127.0.0.1:54321/",
        method: "GET",
        timeout: 250
    })
    m.testObject.send()
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    return m.assertNotEmpty(request)
end function

function TestCase__HttpRequest_SendData()
    m.testObject = HttpRequest({
        url: "http://127.0.0.1:54321/",
        method: "POST",
        headers: { "Content-Type": "application/json" },
        timeout: 250
    })
    m.testObject.send({ password: "12345", user: "johndoe" })
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    result = m.assertNotEmpty(request)
    result += m.assertEqual(request.data, formatJson({ password: "12345", user: "johndoe" }))
    return result
end function

function TestCase__HttpRequest_SendParams()
    m.testObject = HttpRequest({
        url: "http://127.0.0.1:54321/",
        method: "POST",
        headers: { "Content-Type": "application/json" },
        data: { password: "12345", user: "johndoe" },
        timeout: 250
    })
    m.testObject.send()
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    result = m.assertNotEmpty(request)
    result += m.assertEqual(request.data, formatJson({ password: "12345", user: "johndoe" }))
    return result
end function
