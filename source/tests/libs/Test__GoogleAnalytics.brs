'----------------------------------------------------------------
' GA Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__GoogleAnalytics() as Object

    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "Google Analytics Library"

    this.SetUp = GoogleAnalyticsTestSuite__SetUp
    this.TearDown = GoogleAnalyticsTestSuite__TearDown

    ' Helper functions
    this.CreateMockServer = Helper__CreateMockServer
    this.HandleMockServerEvent = Helper__HandleMockServerEvent

    ' Add tests to suite's tests collection
    this.addTest("should create global object", TestCase__GoogleAnalytics_Global)
    this.addTest("should create object with expected functions", TestCase__GoogleAnalytics_Functions)
    this.addTest("should not send tracking data if tracking is not enabled", TestCase__GoogleAnalytics_NotTracking)
    this.addTest("can initialize correct params", TestCase__GoogleAnalytics_Init)
    this.addTest("can set custom params", TestCase__GoogleAnalytics_SetParams)
    this.addTest("can send correct track event request", TestCase__GoogleAnalytics_TrackEvent)
    this.addTest("can send correct track screen request", TestCase__GoogleAnalytics_TrackScreen)
    this.addTest("can send correct track transaction request", TestCase__GoogleAnalytics_TrackTransaction)
    this.addTest("can send correct track item request", TestCase__GoogleAnalytics_TrackItem)
    this.addTest("can send batch tracking events to multiple tracking ids", TestCase__GoogleAnalytics_BatchRequest)
    this.addTest("should cleanup requests", TestCase__GoogleAnalytics_CleanupRequests)

    return this
end function

sub GoogleAnalyticsTestSuite__SetUp()
    m.testObject = GoogleAnalyticsLib()
    ' Override default values for testing purposes
    m.testObject._baseParams = {
        v: "1",
        cid: "ce451d12-e1c2-4f6c-b74a-9ed4aeb66584",
        an : "AppName",
        av : "1.2.3"
    }
    m.testObject._endpoint = "http://127.0.0.1:54321"
    ' Mock server that will receive requests
    m.mockServer = m.CreateMockServer("127.0.0.1", 54321)
end sub

sub GoogleAnalyticsTestSuite__TearDown()
    m.mockServer.close()
    m.mockServer = invalid
    m.testObject = invalid
    m.delete("mockServer")
    m.delete("testObject")
    getGlobalAA().delete("analytics")
end sub

function TestCase__GoogleAnalytics_Global()
    return m.assertNotInvalid(getGlobalAA()["analytics"])
end function

function TestCase__GoogleAnalytics_Functions()
    expectedFunctions = ["init", "setParams", "getPort", "trackEvent", "trackScreen", "trackTransaction", "trackItem"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__GoogleAnalytics_NotTracking()
    result = m.assertFalse(m.testObject._enabled)
    result += m.assertInvalid(m.testObject.trackEvent({category: "app", action: "test"}))
    result += m.assertInvalid(m.testObject.trackScreen({name: "testScreen"}))
    result += m.assertInvalid(m.testObject.trackTransaction({id: "1234", revenue: "12.34"}))
    result += m.assertInvalid(m.testObject.trackItem({transactionId: "1234", name: "dummy", price: "12.34", code: "TEST01", category: "test"}))
    return result
end function

function TestCase__GoogleAnalytics_Init()
    m.testObject.init("D-UMMY-ID")
    result = m.assertEqual(m.testObject._trackingId, "D-UMMY-ID")
    result += m.assertTrue(m.testObject._enabled)
    return result
end function

function TestCase__GoogleAnalytics_SetParams()
    m.testObject.init("D-UMMY-ID")
    baseParams = {
        v: "1",
        cid: "ce451d12-e1c2-4f6c-b74a-9ed4aeb66584",
        an : "AppName",
        av : "1.2.3"
    }
    customParams = {sr: "1280x800", ul: "en-gb"}
    baseParams.append(customParams)
    m.testObject.setParams(customParams)
    result = m.assertEqual(m.testObject._baseParams, baseParams)
    ' Set baseParams back to original ones
    m.testObject._baseParams.delete("sr")
    m.testObject._baseParams.delete("ul")
    return result
end function

function TestCase__GoogleAnalytics_TrackEvent()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackEvent({ category: "app", action: "launch"})
    request = m.HandleMockServerEvent(m.mockServer)
    return m.assertEqual(request.data, "tid=D-UMMY-ID&av=1.2.3&v=1&ea=launch&ec=app&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&an=AppName&t=event&z=1")
end function

function TestCase__GoogleAnalytics_TrackScreen()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackScreen({name: "testScreen"})
    request = m.HandleMockServerEvent(m.mockServer)
    return m.assertEqual(request.data, "tid=D-UMMY-ID&av=1.2.3&cd=testScreen&v=1&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&an=AppName&t=screenview&z=1")
end function

function TestCase__GoogleAnalytics_TrackTransaction()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackTransaction({ id: "OD564", revenue: "10.00"})
    request = m.HandleMockServerEvent(m.mockServer)
    return m.assertEqual(request.data, "tid=D-UMMY-ID&av=1.2.3&tr=10.00&v=1&ti=OD564&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ta=roku&ds=app&an=AppName&t=transaction&z=1")
end function

function TestCase__GoogleAnalytics_TrackItem()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackItem({ transactionId: "OD564", name: "Test01", price: "10.00", code: "TEST001", category: "vod"})
    request = m.HandleMockServerEvent(m.mockServer)
    return m.assertEqual(request.data, "tid=D-UMMY-ID&av=1.2.3&ip=10.00&v=1&ti=OD564&iv=vod&in=Test01&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&an=AppName&ic=TEST001&t=item&z=1")
end function

function TestCase__GoogleAnalytics_BatchRequest()
    processBatchData = function(data as String) as Object
        regex = createObject("roRegex", "\s", "")
        dataArr = regex.split(data)
        return dataArr
    end function

    m.testObject.init(["D-UMMY-ID", "D-UMMY-ID2"])
    m.testObject._sequence = 1
    m.testObject.trackEvent({ category: "app", action: "launch"})
    request = m.HandleMockServerEvent(m.mockServer)
    data = processBatchData(request.data)
    result = m.assertEqual(data[0], "tid=D-UMMY-ID&av=1.2.3&v=1&ea=launch&ec=app&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&an=AppName&t=event&z=1")
    result += m.assertEqual(data[1], "tid=D-UMMY-ID2&av=1.2.3&v=1&ea=launch&ec=app&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&an=AppName&t=event&z=1")
    return result
end function

function TestCase__GoogleAnalytics_CleanupRequests()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackScreen({name: "testScreen"})
    m.HandleMockServerEvent(m.mockServer)
    m.testObject._cleanupRequests()
    return m.assertEmpty(m.testObject._sentRequests)
end function
