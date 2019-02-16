'----------------------------------------------------------------
' Math Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__Math() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "Math Utilities"

    this.SetUp = MathTestSuite__SetUp
    this.TearDown = MathTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("should create object with expected functions", TestCase__Math_Functions)
    this.addTest("ceil should return smallest integer greater than or equal to a given number", TestCase__Math_Ceil)
    this.addTest("floor should return largest integer less than or equal to a given number", TestCase__Math_Floor)
    this.addTest("round should return value rounded to the nearest precision", TestCase__Math_Round)
    this.addTest("min should return smallest of two numbers", TestCase__Math_Min)
    this.addTest("max should return largest of two numbers", TestCase__Math_Max)

    return this
end function

sub MathTestSuite__SetUp()
    m.testObject = MathUtil()
end sub

sub MathTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
end sub


function TestCase__Math_Functions()
    expectedFunctions = ["ceil", "floor", "round", "min", "max"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__Math_Ceil()
    result = m.assertEqual(m.testObject.ceil(1.0), 1)
    result += m.assertEqual(m.testObject.ceil(1.4), 2)
    result += m.assertEqual(m.testObject.ceil(-1.5), -1)
    return result
end function

function TestCase__Math_Floor()
    result = m.assertEqual(m.testObject.floor(1.0), 1)
    result += m.assertEqual(m.testObject.floor(1.4), 1)
    result += m.assertEqual(m.testObject.floor(-1.5), -2)
    return result
end function

function TestCase__Math_Round()
    result = m.assertEqual(m.testObject.round(1.1459), 1.0)
    result += m.assertEqual(m.testObject.round(1.1459, 3), 1.146)
    result += m.assertEqual(m.testObject.round(-1.1459, 2), -1.15)
    return result
end function

function TestCase__Math_Min()
    result = m.assertEqual(m.testObject.min(1,2), 1)
    result += m.assertEqual(m.testObject.min(1.14, 1.15), 1.14)
    result += m.assertEqual(m.testObject.min(-1.5, -2), -2)
    return result
end function

function TestCase__Math_Max()
    result = m.assertEqual(m.testObject.max(1,2), 2)
    result += m.assertEqual(m.testObject.max(1.14, 1.15), 1.15)
    result += m.assertEqual(m.testObject.max(-1.5, -2), -1.5)
    return result
end function
