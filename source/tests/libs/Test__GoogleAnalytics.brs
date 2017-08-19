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
    this.addTest("init should set correct properties", TestCase__GoogleAnalytics_Init)

    return this
end function

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
sub GoogleAnalyticsTestSuite__SetUp()
    ' Target testing object. To avoid the object creation in each test
    ' we create instance of target object here and use it in tests as m.targetTestObject.
    m.testObject = GoogleAnalyticsLib()
end sub

'----------------------------------------------------------------
' This function called immediately after running tests of current suite.
' This function called to clean or remove all data for testing.
'----------------------------------------------------------------
sub GoogleAnalyticsTestSuite__TearDown()
    ' Remove all the test data
    m.testObject = invalid
    m.delete("testObject")
    getGlobalAA().delete("analytics")
end sub


function TestCase__GoogleAnalytics_Global()
    return m.assertNotInvalid(getGlobalAA()["analytics"])
end function

function TestCase__GoogleAnalytics_Functions()
    expectedFunctions = ["init", "getPort", "trackEvent", "trackScreen", "trackTransaction", "trackItem", "handleResponse"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__GoogleAnalytics_NotTracking()
    expectedValues = [invalid, invalid, invalid, invalid]
    values = []
    values.push(m.testObject.trackEvent({category: "app", action: "test"}))
    values.push(m.testObject.trackScreen({name: "testScreen"}))
    values.push(m.testObject.trackTransaction({id: "1234", revenue: "12.34"}))
    values.push(m.testObject.trackItem({transactionId: "1234", name: "dummy", price: "12.34", code: "TEST01", category: "test"}))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__GoogleAnalytics_Init()
    m.testObject.init("D-UMMY-ID")
    expectedValues = ["D-UMMY-ID", true]
    values = []
    values.push(m.testObject._trackingID)
    values.push(m.testObject._isTracking)
    return m.assertEqual(values, expectedValues)
end function
