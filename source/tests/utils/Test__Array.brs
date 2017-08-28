'----------------------------------------------------------------
' Array Test Suite
'
' @return A configured TestSuite object.
'----------------------------------------------------------------
function TestSuite__Array() as Object
    ' Inherite your test suite from BaseTestSuite
    this = BaseTestSuite()

    ' Test suite name for log statistics
    this.Name = "Array Utilities"

    this.SetUp = ArrayTestSuite__SetUp
    this.TearDown = ArrayTestSuite__TearDown

    ' Add tests to suite's tests collection
    this.addTest("should create object with expected functions", TestCase__Array_Functions)
    this.addTest("contains should check whether or not the array contains given value", TestCase__Array_Contains)
    this.addTest("indexOf should return first index of element equal to given value", TestCase__Array_IndexOf)
    this.addTest("lastIndexOf should return last index of element equal to given value", TestCase__Array_LastIndexOf)
    this.addTest("slice should extract a section of the array", TestCase__Array_Slice)
    this.addTest("map should create an array with the results of calling the function on every element of the array", TestCase__Array_Map)
    this.addTest("reduce should reduce array to a single accumulator value", TestCase__Array_Reduce)

    return this
end function

sub ArrayTestSuite__SetUp()
    m.testObject = ArrayUtil()
end sub

sub ArrayTestSuite__TearDown()
    m.testObject = invalid
    m.delete("testObject")
end sub


function TestCase__Array_Functions()
    expectedFunctions = ["contains", "indexOf", "lastIndexOf", "slice", "map", "reduce"]
    return m.assertAAHasKeys(m.testObject, expectedFunctions)
end function

function TestCase__Array_Contains()
    expectedValues = [true,false,false]
    arr = [1,2,3,4,5]
    values = []
    values.push(m.testObject.contains(arr, 3))
    values.push(m.testObject.contains(arr, 8))
    values.push(m.testObject.contains(arr, 1.5))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Array_IndexOf()
    expectedValues = [2,-1,-1]
    arr = [1,2,3,4,5]
    values = []
    values.push(m.testObject.indexOf(arr, 3))
    values.push(m.testObject.indexOf(arr, 8))
    values.push(m.testObject.indexOf(arr, 1.5))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Array_LastIndexOf()
    expectedValues = [3,-1,-1]
    arr = [1,2,3,3,5]
    values = []
    values.push(m.testObject.lastIndexOf(arr, 3))
    values.push(m.testObject.lastIndexOf(arr, 8))
    values.push(m.testObject.lastIndexOf(arr, 1.5))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Array_Slice()
    expectedValues = [[2,3,4],[1,2,3],[1,2,3,4,5],[]]
    arr = [1,2,3,4,5]
    values = []
    values.push(m.testObject.slice(arr, 1, 3))
    values.push(m.testObject.slice(arr, -1, 2))
    values.push(m.testObject.slice(arr, 0, 6))
    values.push(m.testObject.slice(arr, 3, 2))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Array_Map()
    expectedValues = [[2,3,4,5,6],[0,1,2,3,4],[]]
    arr = [1,2,3,4,5]
    values = []
    addOne = function(element, index, arr)
        return element + 1
    end function
    returnIndex = function(element, index, arr)
        return index
    end function
    values.push(m.testObject.map(arr, addOne))
    values.push(m.testObject.map(arr, returnIndex))
    values.push(m.testObject.map([], addOne))
    return m.assertEqual(values, expectedValues)
end function

function TestCase__Array_Reduce()
    expectedValues = [15,[1,2,3,4,5],10]
    arr1 = [1,2,3,4,5]
    arr2 = [[1,2],[3,4],[5]]
    values = []
    reduceToNum = function(acc, element, index, arr)
        return acc + element
    end function
    reduceToArr = function(acc, element, index, arr)
        acc.append(element)
        return acc
    end function
    values.push(m.testObject.reduce(arr1, reduceToNum))
    values.push(m.testObject.reduce(arr2, reduceToArr))
    values.push(m.testObject.reduce([], reduceToNum, 10))
    return m.assertEqual(values, expectedValues)
end function
