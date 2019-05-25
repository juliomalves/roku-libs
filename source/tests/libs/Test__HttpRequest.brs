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
    this.addTest("setTimeout should be chainable and set timeout property", TestCase__HttpRequest_SetTimeout)
    this.addTest("setInterval should be chainable and set interval property", TestCase__HttpRequest_SetInterval)
    this.addTest("setRetries should be chainable and set retries property", TestCase__HttpRequest_SetRetries)
    this.addTest("setRequestHeaders should be chainable and set requestHeaders property", TestCase__HttpRequest_SetRequestHeaders)
    this.addTest("open should set correct properties", TestCase__HttpRequest_Open)
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
        "open", 
        "send", 
        "abort", 
        "setTimeout", 
        "setInterval", 
        "setRetries", 
        "setRequestHeaders", 
        "getPort", 
        "getCookies"
    ]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__HttpRequest_SetTimeout()
    m.testObject.setTimeout(2000).setTimeout(1000)
    return m.assertEqual(m.testObject._timeout, 1000)
end function

function TestCase__HttpRequest_SetInterval()
    m.testObject.setInterval(100).setInterval(500)
    return m.assertEqual(m.testObject._interval, 500)
end function

function TestCase__HttpRequest_SetRetries()
    m.testObject.setRetries(3).setRetries(2)
    return m.assertEqual(m.testObject._retries, 2)
end function

function TestCase__HttpRequest_SetRequestHeaders()
    m.testObject.setRequestHeaders({"Content-Type": "text/plain"}).setRequestHeaders({"Content-Type": "application/json"})
    return m.assertEqual(m.testObject._requestHeaders, {"Content-Type": "application/json"})
end function

function TestCase__HttpRequest_Open()
    m.testObject.open("http://127.0.0.1:54321/", "GET")
    result = m.assertEqual(m.testObject._url, "http://127.0.0.1:54321/")
    result += m.assertEqual(m.testObject._method, "GET")
    return result
end function

function TestCase__HttpRequest_Send()
    m.testObject = HttpRequest()
    m.testObject.setTimeout(250)
    m.testObject.open("http://127.0.0.1:54321/", "GET")
    m.testObject.send()
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    return m.assertNotEmpty(request)
end function

function TestCase__HttpRequest_SendData()
    m.testObject = HttpRequest()
    m.testObject.setTimeout(250).setRequestHeaders({"Content-Type": "application/json"})
    m.testObject.open("http://127.0.0.1:54321/", "POST")
    m.testObject.send({password: "12345", user: "johndoe"})
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    result = m.assertNotEmpty(request)
    result += m.assertEqual(request.data, formatJson({password: "12345", user: "johndoe"}))
    return result
end function

function TestCase__HttpRequest_SendParams()
    m.testObject = HttpRequest({
        url: "http://127.0.0.1:54321/",
        method: "POST",
        headers: {"Content-Type": "application/json"},
        data: {password: "12345", user: "johndoe"}
    })
    m.testObject.setTimeout(250)
    m.testObject.send()
    m.testObject.abort()
    request = m.mockServer.handleEvent()
    result = m.assertNotEmpty(request)
    result += m.assertEqual(request.data, formatJson({password: "12345", user: "johndoe"}))
    return result
end function
