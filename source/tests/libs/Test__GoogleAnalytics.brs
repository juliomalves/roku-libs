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

sub GoogleAnalyticsTestSuite__SetUp()
    m.testObject = GoogleAnalyticsLib()
end sub

sub GoogleAnalyticsTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
    getGlobalAA().delete("analytics")
end sub

function TestCase__GoogleAnalytics_Global()
    return m.assertNotInvalid(getGlobalAA()["analytics"])
end function

function TestCase__GoogleAnalytics_Functions()
    expectedFunctions = ["init", "getPort", "trackEvent", "trackScreen", "trackTransaction", "trackItem"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__GoogleAnalytics_NotTracking()
    result = m.assertFalse(m.testObject._enabled)
    result = m.assertInvalid(m.testObject.trackEvent({category: "app", action: "test"})) + result
    result = m.assertInvalid(m.testObject.trackScreen({name: "testScreen"})) + result
    result = m.assertInvalid(m.testObject.trackTransaction({id: "1234", revenue: "12.34"})) + result
    result = m.assertInvalid(m.testObject.trackItem({transactionId: "1234", name: "dummy", price: "12.34", code: "TEST01", category: "test"})) + result
    return result
end function

function TestCase__GoogleAnalytics_Init()
    m.testObject.init("D-UMMY-ID")
    result = m.assertEqual(m.testObject._trackingID, "D-UMMY-ID")
    result = m.assertTrue(m.testObject._enabled) + result
    return result
end function
