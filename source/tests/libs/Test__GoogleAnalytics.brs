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

    ' Add tests to suite's tests collection
    this.addTest("should create global object", TestCase__GoogleAnalytics_Global)
    this.addTest("should create object with expected functions", TestCase__GoogleAnalytics_Functions)
    this.addTest("should not send tracking data if tracking is not enabled", TestCase__GoogleAnalytics_NotTracking)
    this.addTest("can initialize correct params", TestCase__GoogleAnalytics_Init)
    this.addTest("can set custom params", TestCase__GoogleAnalytics_SetParams)
    this.addTest("can send track event request", TestCase__GoogleAnalytics_TrackEvent)
    this.addTest("can send track screen request", TestCase__GoogleAnalytics_TrackScreen)
    this.addTest("can send track transaction request", TestCase__GoogleAnalytics_TrackTransaction)
    this.addTest("can send track item request", TestCase__GoogleAnalytics_TrackItem)
    this.addTest("can send track timing request", TestCase__GoogleAnalytics_TrackTiming)
    this.addTest("can send track exception request", TestCase__GoogleAnalytics_TrackException)
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
        av : "1.2.3",
        ds : "app"
    }
    m.testObject._endpoint = "http://127.0.0.1:54321"
    m.testObject._endpointBatch = "http://127.0.0.1:54321"
    ' Mock server that will receive requests
    m.mockServer = MockServer()
    m.mockServer.create("127.0.0.1", 54321)
end sub

sub GoogleAnalyticsTestSuite__TearDown()
    m.mockServer.destroy()
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
    expectedFunctions = ["init", "setParams", "getPort", "trackEvent", "trackScreen", "trackTransaction", "trackItem", "trackTiming", "trackException"]
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
    expectedParams = {
        v: "1",
        cid: "ce451d12-e1c2-4f6c-b74a-9ed4aeb66584",
        an : "AppName",
        av : "1.2.3",
        ds : "app",
        sr: "1280x800", 
        ul: "en-gb"
    }
    m.testObject.setParams({sr: "1280x800", ul: "en-gb"})
    result = m.assertEqual(m.testObject._baseParams, expectedParams)
    ' Set baseParams back to original ones
    m.testObject._baseParams.delete("sr")
    m.testObject._baseParams.delete("ul")
    return result
end function

function TestCase__GoogleAnalytics_TrackEvent()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackEvent({ category: "app", action: "launch"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&ea=launch&ec=app&t=event&v=1&z=1")
end function

function TestCase__GoogleAnalytics_TrackScreen()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackScreen({name: "testScreen"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cd=testScreen&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&t=screenview&v=1&z=1")
end function

function TestCase__GoogleAnalytics_TrackTransaction()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackTransaction({ id: "OD564", revenue: "10.00"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&t=transaction&ti=OD564&tr=10.00&v=1&z=1")
end function

function TestCase__GoogleAnalytics_TrackItem()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackItem({ transactionId: "OD564", name: "Test01", price: "10.00", code: "TEST001", category: "vod"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&ic=TEST001&in=Test01&ip=10.00&iv=vod&t=item&ti=OD564&v=1&z=1")
end function

function TestCase__GoogleAnalytics_TrackTiming()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackTiming({category: "test", variable: "test", time: "1000"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&t=timing&utc=test&utt=1000&utv=test&v=1&z=1")
end function

function TestCase__GoogleAnalytics_TrackException()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackException({description: "description", isFatal: "1"})
    request = m.mockServer.handleEvent()
    return m.assertEqual(request.data, "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&exd=description&exf=1&t=exception&v=1&z=1")
end function

function TestCase__GoogleAnalytics_BatchRequest()
    processBatchData = function(data as Dynamic) as Object
        if data = invalid then return []
        regex = createObject("roRegex", "\s", "")
        dataArr = regex.split(data)
        return dataArr
    end function

    expectedData = [
        "tid=D-UMMY-ID&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&ea=launch&ec=app&t=event&v=1&z=1",
        "tid=D-UMMY-ID2&an=AppName&av=1.2.3&cid=ce451d12-e1c2-4f6c-b74a-9ed4aeb66584&ds=app&ea=launch&ec=app&t=event&v=1&z=1"
    ]
    m.testObject.init(["D-UMMY-ID", "D-UMMY-ID2"])
    m.testObject._sequence = 1
    m.testObject.trackEvent({ category: "app", action: "launch"})
    request = m.mockServer.handleEvent()
    dataArr = processBatchData(request.data)
    result = m.assertNotEmpty(dataArr)
    for i = 0 to dataArr.count() - 1
        result += m.assertEqual(dataArr[i], expectedData[i])
    end for
    return result
end function

function TestCase__GoogleAnalytics_CleanupRequests()
    m.testObject.init("D-UMMY-ID")
    m.testObject._sequence = 1
    m.testObject.trackScreen({name: "testScreen"})
    request = m.mockServer.handleEvent()
    m.testObject._cleanupRequests()
    return m.assertEmpty(m.testObject._sentRequests)
end function
