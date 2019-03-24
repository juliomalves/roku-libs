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
    this.addTest("isNumber should check if value is a number", TestCase__Math_IsNumber)
    this.addTest("isInt should check if value is an integer", TestCase__Math_isInt)
    this.addTest("isFloat should check if value is a float", TestCase__Math_isFloat)
    this.addTest("isDouble should check if value is a double", TestCase__Math_isDouble)
    this.addTest("ceil should return smallest integer greater than or equal to a given number", TestCase__Math_Ceil)
    this.addTest("floor should return largest integer less than or equal to a given number", TestCase__Math_Floor)
    this.addTest("round should return value rounded to the nearest precision", TestCase__Math_Round)
    this.addTest("min should return smallest of two numbers", TestCase__Math_Min)
    this.addTest("max should return largest of two numbers", TestCase__Math_Max)
    this.addTest("power should return base to the exponent power", TestCase__Math_Power)

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
    expectedFunctions = ["isNumber", "isInt", "isFloat", "isDouble", "ceil", "floor", "round", "min", "max", "power"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__Math_IsNumber()
    result = m.assertTrue(m.testObject.isNumber(0))
    result += m.assertTrue(m.testObject.isNumber(-1))
    result += m.assertTrue(m.testObject.isNumber(1.5))
    result += m.assertTrue(m.testObject.isNumber(1.5D-2))
    result += m.assertFalse(m.testObject.isNumber([]))
    result += m.assertFalse(m.testObject.isNumber(true))
    result += m.assertFalse(m.testObject.isNumber({}))
    result += m.assertFalse(m.testObject.isNumber(invalid))
    return result
end function

function TestCase__Math_isInt()
    result = m.assertTrue(m.testObject.isInt(0))
    result += m.assertTrue(m.testObject.isInt(10))
    result += m.assertTrue(m.testObject.isInt(-200))
    result += m.assertFalse(m.testObject.isInt(1.5))
    result += m.assertFalse(m.testObject.isInt(1.5D-2))
    return result
end function

function TestCase__Math_isFloat()
    result = m.assertTrue(m.testObject.isFloat(1.5))
    result += m.assertTrue(m.testObject.isFloat(1.5E+2))
    result += m.assertTrue(m.testObject.isFloat(-2.0))
    result += m.assertFalse(m.testObject.isFloat(10))
    result += m.assertFalse(m.testObject.isFloat(1.5D-2))
    return result
end function

function TestCase__Math_isDouble()
    result = m.assertTrue(m.testObject.isDouble(1.5D-2))
    result += m.assertFalse(m.testObject.isDouble(1.5))
    result += m.assertFalse(m.testObject.isDouble(1.5E+2))
    result += m.assertFalse(m.testObject.isDouble(10))
    return result
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
    result = m.assertEqual(m.testObject.max(1, 2), 2)
    result += m.assertEqual(m.testObject.max(1.14, 1.15), 1.15)
    result += m.assertEqual(m.testObject.max(-1.5, -2), -1.5)
    return result
end function

function TestCase__Math_Power()
    result = m.assertEqual(m.testObject.power(2, 10), 1024)
    result += m.assertEqual(m.testObject.power(-7, 2), 49)
    result += m.assertEqual(m.testObject.power(-7, 3), -343)
    return result
end function
