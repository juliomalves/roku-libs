'----------------------------------------------------------------
' String Test Suite
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
    this.addTest("isString should check if element is a string", TestCase__String_IsString)
    this.addTest("charAt should return character at the specified index", TestCase__String_CharAt)
    this.addTest("contains should check whether or not the string contains given substring", TestCase__String_Contains)
    this.addTest("indexOf should return first index of given substring in the string", TestCase__String_IndexOf)
    this.addTest("match should retrieve matching substrings against a regular expression", TestCase__String_Match)
    this.addTest("replace should substitute matched substring with new substring", TestCase__String_Replace)
    this.addTest("truncate should truncate string to given length and append ellipsis", TestCase__String_Truncate)
    this.addTest("concat should concatenate the second string argument to the first string", TestCase__String_Concat)
    this.addTest("toString should convert any value to a string representation", TestCase__String_ToString)
    this.addTest("hash functions should generate correct hashes", TestCase__String_ToHash)

    return this
end function

sub StringTestSuite__SetUp()
    m.testObject = StringUtil()
end sub

sub StringTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
end sub


function TestCase__String_Functions()
    expectedFunctions = ["isString", "charAt", "contains", "indexOf", "match", "replace", "truncate", "concat", "toString", "toMD5", "toSHA1", "toSHA256", "toSHA512", "_hash"]
    result = m.assertAAHasKeys(m.testObject, expectedFunctions)
    result += m.assertEqual(m.testObject.keys().count(), expectedFunctions.count())
    return result
end function

function TestCase__String_IsString()
    result = m.assertTrue(m.testObject.isString("Hello World!"))
    result += m.assertTrue(m.testObject.isString(""))
    result += m.assertFalse(m.testObject.isString(true))
    result += m.assertFalse(m.testObject.isString(1.5))
    result += m.assertFalse(m.testObject.isString({}))
    result += m.assertFalse(m.testObject.isString(invalid))
    return result
end function

function TestCase__String_CharAt()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.charAt(str, 1), "e")
    result += m.assertEqual(m.testObject.charAt(str, 12), "")
    result += m.assertEqual(m.testObject.charAt(str, -1), "H")
    return result
end function

function TestCase__String_Contains()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.contains(str, "Hell"), true)
    result += m.assertEqual(m.testObject.contains(str, "Hell", 2), false)
    result += m.assertEqual(m.testObject.contains(str, "Bye"), false)
    return result
end function

function TestCase__String_IndexOf()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.indexOf(str, "Hell"), 0)
    result += m.assertEqual(m.testObject.indexOf(str, "Hell", 2), -1)
    result += m.assertEqual(m.testObject.indexOf(str, "Bye"), -1)
    return result
end function

function TestCase__String_Match()
    str = "AbraCadabra"
    result = m.assertEqual(m.testObject.match(str, "cad"), [])
    result += m.assertEqual(m.testObject.match(str, "cad", "i"), ["Cad"])
    result += m.assertEqual(m.testObject.match(str, "(ab)(ra)", "i"), ["Abra","Ab","ra"])
    return result
end function

function TestCase__String_Replace()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.replace(str, "Hello", "Bye"), "Bye World!")
    result += m.assertEqual(m.testObject.replace(str, "!", "?"), "Hello World?")
    result += m.assertEqual(m.testObject.replace(str, "Hi", "Bye"), "Hello World!")
    return result
end function

function TestCase__String_Truncate()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.truncate(str, 5), "Hello")
    result += m.assertEqual(m.testObject.truncate(str, 5, "..."), "Hello...")
    result += m.assertEqual(m.testObject.truncate(str, 13, "..."), "Hello World!")
    return result
end function

function TestCase__String_Concat()
    str = "Hello "
    result = m.assertEqual(m.testObject.concat(str, "World!"), "Hello World!")
    result += m.assertEqual(m.testObject.concat(str, 9000), "Hello 9000")
    result += m.assertEqual(m.testObject.concat(str, false), "Hello false")
    return result
end function

function TestCase__String_ToString()
    nowTime = createObject("roDateTime")
    result = m.assertEqual(m.testObject.toString("Hello World!"), "Hello World!")
    result += m.assertEqual(m.testObject.toString(9000), "9000")
    result += m.assertEqual(m.testObject.toString(false), "false")
    result += m.assertEqual(m.testObject.toString([1,"2"]), "1,2")
    result += m.assertEqual(m.testObject.toString({num:3}), "<Component: roAssociativeArray>")
    result += m.assertEqual(m.testObject.toString(nowTime), nowTime.asSeconds().toStr())
    result += m.assertEqual(m.testObject.toString(invalid), "invalid")
    result += m.assertEqual(m.testObject.toString(uninitVar), "<uninitialized>")
    return result
end function

function TestCase__String_ToHash()
    str = "Hello World!"
    result = m.assertEqual(m.testObject.toMD5(str), "ed076287532e86365e841e92bfc50d8c")
    result += m.assertEqual(m.testObject.toSHA1(str), "2ef7bde608ce5404e97d5f042f95f89f1c232871")
    result += m.assertEqual(m.testObject.toSHA256(str), "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069")
    result += m.assertEqual(m.testObject.toSHA512(str), "861844d6704e8573fec34d967e20bcfef3d424cf48be04e6dc08f2bd58c729743371015ead891cc3cf1c9d34b49264b510751b1ff9e537937bc46b5d6ff4ecc8")
    return result
end function
