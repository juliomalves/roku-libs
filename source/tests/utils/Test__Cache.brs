'----------------------------------------------------------------
' Cache Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__Cache() as Object

    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "Cache Library"

    this.SetUp = CacheTestSuite__SetUp
    this.TearDown = CacheTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("should create object with expected functions", TestCase__Cache_Functions)
    this.addTest("should cache a value", TestCase__Cache_Put)
    this.addTest("should return wether a value exists in cache", TestCase__Cache_Match)
    this.addTest("should delete a cached value", TestCase__Cache_Delete)
    this.addTest("should return a cached value", TestCase__Cache_Get)
    this.addTest("should not return value if TTL has expired", TestCase__Cache_Get_Expired)

    return this
end function

sub CacheTestSuite__SetUp()
    m.testObject = CacheUtil("testKey", { ttl: 1 })
end sub

sub CacheTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
end sub

function TestCase__Cache_Functions()
    expectedFunctions = [
        "match",
        "put",
        "delete",
        "get"
    ]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__Cache_Put()
    putValueInCache = m.testObject.put("value to cache")
    return m.assertEqual(putValueInCache, true)
end function

function TestCase__Cache_Match()
    m.testObject.put("value to cache")
    hasMatch = m.testObject.match()
    return m.assertEqual(hasMatch, true)
end function

function TestCase__Cache_Delete()
    m.testObject.put("value to cache")
    hasDeletedValue = m.testObject.delete()
    hasMatch = m.testObject.match()
    result = m.assertEqual(hasDeletedValue, true)
    result += m.assertEqual(hasMatch, false)
    return result
end function

function TestCase__Cache_Get()
    value = "value to cache"
    m.testObject.put(value)
    cachedValue = m.testObject.get()
    return m.assertEqual(cachedValue, value)
end function

function TestCase__Cache_Get_Expired()
    m.testObject.put("value to cache")
    sleep(1500)
    cachedValue = m.testObject.get()
    return m.assertEqual(cachedValue, invalid)
end function
