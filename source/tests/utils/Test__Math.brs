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
    expectedValues = [1,2,-1]
    values = []
    values.push(m.testObject.ceil(1.0))
    values.push(m.testObject.ceil(1.4))
    values.push(m.testObject.ceil(-1.5))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Math_Floor()
    expectedValues = [1,1,-2]
    values = []
    values.push(m.testObject.floor(1.0))
    values.push(m.testObject.floor(1.4))
    values.push(m.testObject.floor(-1.5))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Math_Round()
    expectedValues = [1,1.146,-1.15]
    values = []
    values.push(m.testObject.round(1.1459))
    values.push(m.testObject.round(1.1459, 3))
    values.push(m.testObject.round(-1.1459, 2))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Math_Min()
    expectedValues = [1,1.14,-2]
    values = []
    values.push(m.testObject.min(1,2))
    values.push(m.testObject.min(1.14, 1.15))
    values.push(m.testObject.min(-1.5, -2))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Math_Max()
    expectedValues = [2,1.15,-1.5]
    values = []
    values.push(m.testObject.max(1,2))
    values.push(m.testObject.max(1.14, 1.15))
    values.push(m.testObject.max(-1.5, -2))
    return m.assertEqual(values, expectedValues)
end function
