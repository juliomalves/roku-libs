'----------------------------------------------------------------
' Array Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__String() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "String Utilities"

    this.SetUp = StringTestSuite__SetUp
    this.TearDown = StringTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("should create object with expected functions", TestCase__String_Functions)
    this.addTest("charAt should return character at the specified index", TestCase__String_CharAt)
    this.addTest("contains should check whether or not the string contains given substring", TestCase__String_Contains)
    this.addTest("indexOf should return first index of given substring in the string", TestCase__String_IndexOf)
    this.addTest("match should retrieve matching substrings against a regular expression", TestCase__String_Match)
    this.addTest("replace should substitute matched substring with new substring", TestCase__String_Replace)
    this.addTest("truncate should truncate string to given length and append ellipsis", TestCase__String_Truncate)
    this.addTest("hash functions should generate correct hashes", TestCase__String_ToHash)

    return this
end function

'----------------------------------------------------------------
' This function called immediately before running tests of current suite.
' This function called to prepare all data for testing.
'----------------------------------------------------------------
sub StringTestSuite__SetUp()
    m.testObject = StringUtil()
end sub

'----------------------------------------------------------------
' This function called immediately after running tests of current suite.
' This function called to clean or remove all data for testing.
'----------------------------------------------------------------
sub StringTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
end sub


function TestCase__String_Functions()
    expectedFunctions = ["charAt", "contains", "indexOf", "match", "replace", "truncate", "toMD5", "toSHA1", "toSHA256", "toSHA512"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__String_CharAt()
    expectedValues = ["e","","H"]
    str = "Hello World!"
    values = []
    values.push(m.testObject.charAt(str, 1))
    values.push(m.testObject.charAt(str, 12))
    values.push(m.testObject.charAt(str, -1))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_Contains()
    expectedValues = [true,false,false]
    str = "Hello World!"
    values = []
    values.push(m.testObject.contains(str, "Hell"))
    values.push(m.testObject.contains(str, "Hell", 2))
    values.push(m.testObject.contains(str, "Bye"))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_IndexOf()
    expectedValues = [0,-1,-1]
    str = "Hello World!"
    values = []
    values.push(m.testObject.indexOf(str, "Hell"))
    values.push(m.testObject.indexOf(str, "Hell", 2))
    values.push(m.testObject.indexOf(str, "Bye"))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_Match()
    expectedValues = [[],["Cad"],["Abra","Ab","ra"]]
    str = "AbraCadabra"
    values = []
    values.push(m.testObject.match(str, "cad"))
    values.push(m.testObject.match(str, "cad", "i"))
    values.push(m.testObject.match(str, "(ab)(ra)", "i"))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_Replace()
    expectedValues = ["Bye World!","Hello World?","Hello World!"]
    str = "Hello World!"
    values = []
    values.push(m.testObject.replace(str, "Hello", "Bye"))
    values.push(m.testObject.replace(str, "!", "?"))
    values.push(m.testObject.replace(str, "Hi", "Bye"))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_Truncate()
    expectedValues = ["Hello","Hello...","Hello World!"]
    str = "Hello World!"
    values = []
    values.push(m.testObject.truncate(str, 5))
    values.push(m.testObject.truncate(str, 5, "..."))
    values.push(m.testObject.truncate(str, 13, "..."))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__String_ToHash()
    expectedValues = [
        "ed076287532e86365e841e92bfc50d8c",
        "2ef7bde608ce5404e97d5f042f95f89f1c232871",
        "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069",
        "861844d6704e8573fec34d967e20bcfef3d424cf48be04e6dc08f2bd58c729743371015ead891cc3cf1c9d34b49264b510751b1ff9e537937bc46b5d6ff4ecc8"
    ]
    str = "Hello World!"
    values = []
    values.push(m.testObject.toMD5(str))
    values.push(m.testObject.toSHA1(str))
    values.push(m.testObject.toSHA256(str))
    values.push(m.testObject.toSHA512(str))
    return m.assertEqual(values, expectedValues)
end function
