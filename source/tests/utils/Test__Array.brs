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
    this.addTest("isArray should check if element is an array", TestCase__Array_IsArray)
    this.addTest("contains should check whether or not the array contains given value", TestCase__Array_Contains)
    this.addTest("indexOf should return first index of element equal to given value", TestCase__Array_IndexOf)
    this.addTest("lastIndexOf should return last index of element equal to given value", TestCase__Array_LastIndexOf)
    this.addTest("slice should extract a section of the array", TestCase__Array_Slice)
    this.addTest("fill should changes all elements within a range of indices to given value", TestCase__Array_Fill)
    this.addTest("flat should create an array with all sub-array elements concatenated into it", TestCase__Array_Flat)
    this.addTest("map should create an array with the results of calling the function on every element of the array", TestCase__Array_Map)
    this.addTest("reduce should reduce array to a single accumulator value", TestCase__Array_Reduce)
    this.addTest("filter should filter array with elements that satisfy the testing function", TestCase__Array_Filter)
    this.addTest("find should return the value of the first element in the array that satisfies the testing function", TestCase__Array_Find)
    this.addTest("findIndex should return the index of the first element in the array that satisfies the testing function", TestCase__Array_FindIndex)
    this.addTest("grouBy should return the array elements grouped by the given key", TestCase__Array_GroupBy)

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
    expectedFunctions = [
        "isArray",
        "contains",
        "indexOf",
        "lastIndexOf",
        "slice",
        "fill",
        "flat",
        "map",
        "reduce",
        "filter",
        "find",
        "findIndex",
        "groupBy"
    ]
    result = m.assertAAHasKeys(m.testObject, expectedFunctions)
    result += m.assertEqual(m.testObject.keys().count(), expectedFunctions.count())
    return result
end function

function TestCase__Array_IsArray()
    result = m.assertTrue(m.testObject.isArray([1,2,3,4,5]))
    result += m.assertTrue(m.testObject.isArray([]))
    result += m.assertFalse(m.testObject.isArray(true))
    result += m.assertFalse(m.testObject.isArray(1.5))
    result += m.assertFalse(m.testObject.isArray({}))
    result += m.assertFalse(m.testObject.isArray(invalid))
    return result
end function

function TestCase__Array_Contains()
    arr = [1,2,3,4,5]
    result = m.assertTrue(m.testObject.contains(arr, 3))
    result += m.assertFalse(m.testObject.contains(arr, 8))
    result += m.assertFalse(m.testObject.contains(arr, 1.5))
    return result
end function

function TestCase__Array_IndexOf()
    arr = [1,2,3,4,5]
    result = m.assertEqual(m.testObject.indexOf(arr, 3), 2)
    result += m.assertEqual(m.testObject.indexOf(arr, 8), -1)
    result += m.assertEqual(m.testObject.indexOf(arr, 1.5), -1)
    return result
end function

function TestCase__Array_LastIndexOf()
    arr = [1,2,3,3,5]
    result = m.assertEqual(m.testObject.lastIndexOf(arr, 3), 3)
    result += m.assertEqual(m.testObject.lastIndexOf(arr, 8), -1)
    result += m.assertEqual(m.testObject.lastIndexOf(arr, 1.5), -1)
    return result
end function

function TestCase__Array_Slice()
    arr = [1,2,3,4,5]
    result = m.assertEqual(m.testObject.slice(arr, 1, 3), [2,3,4])
    result += m.assertEqual(m.testObject.slice(arr, -2), [4,5])
    result += m.assertEqual(m.testObject.slice(arr, -4, -2), [2,3,4])
    result += m.assertEqual(m.testObject.slice(arr, 0, 6), [1,2,3,4,5])
    result += m.assertEqual(m.testObject.slice(arr, 3, 2), [])
    return result
end function

function TestCase__Array_Fill()
    arr = [1,2,3,4,5]
    result = m.assertEqual(m.testObject.fill(arr, 0), [0,0,0,0,0])
    result += m.assertEqual(m.testObject.fill(arr, 0, 2), [1,2,0,0,0])
    result += m.assertEqual(m.testObject.fill(arr, 0, 1, 3), [1,0,0,0,5])
    result += m.assertEqual(m.testObject.fill(arr, 0, -1, 10), [0,0,0,0,0])
    result += m.assertEqual(m.testObject.fill(invalid, 0), invalid)
    result += m.assertEqual(m.testObject.fill([], 0), [])
    return result
end function

function TestCase__Array_Flat()
    arr = [0, 1, 2, [3, 4]]
    result = m.assertEqual(m.testObject.flat(arr), [0, 1, 2, 3, 4])
    result += m.assertEqual(m.testObject.flat([]), [])
    return result
end function

function TestCase__Array_Map()
    addOne = function(element, index, arr)
        return element + 1
    end function
    returnIndex = function(element, index, arr)
        return index
    end function
    arr = [1,2,3,4,5]
    result = m.assertEqual(m.testObject.map(arr, addOne), [2,3,4,5,6])
    result += m.assertEqual(m.testObject.map(arr, returnIndex), [0,1,2,3,4])
    result += m.assertEqual(m.testObject.map([], addOne), [])
    return result
end function

function TestCase__Array_Reduce()
    reduceToNum = function(acc, element, index, arr)
        return acc + element
    end function
    reduceToArr = function(acc, element, index, arr)
        acc.append(element)
        return acc
    end function
    arr1 = [1,2,3,4,5]
    arr2 = [[1,2],[3,4],[5]]
    result = m.assertEqual(m.testObject.reduce(arr1, reduceToNum), 15)
    result += m.assertEqual(m.testObject.reduce(arr2, reduceToArr), [1,2,3,4,5])
    result += m.assertEqual(m.testObject.reduce([], reduceToNum, 10), 10)
    return result
end function

function TestCase__Array_Filter()
    moreThanSixLetters = function(element, index, arr)
        return element.len() >= 6
    end function
    startsWithL = function(element, index, arr)
        return element.left(1) = "l"
    end function
    arr = ["light", "limit", "exuberant", "destruction"]
    result = m.assertEqual(m.testObject.filter(arr, moreThanSixLetters), ["exuberant", "destruction"])
    result += m.assertEqual(m.testObject.filter(arr, startsWithL), ["light", "limit"])
    result += m.assertEqual(m.testObject.filter([], moreThanSixLetters), [])
    return result
end function

function TestCase__Array_Find()
    moreThanSixLetters = function(element, index, arr)
        return element.len() >= 6
    end function
    startsWithL = function(element, index, arr)
        return element.left(1) = "l"
    end function
    arr = ["light", "limit", "exuberant", "destruction"]
    result = m.assertEqual(m.testObject.find(arr, moreThanSixLetters), "exuberant")
    result += m.assertEqual(m.testObject.find(arr, startsWithL), "light")
    result += m.assertEqual(m.testObject.find([], moreThanSixLetters), invalid)
    return result
end function

function TestCase__Array_FindIndex()
    moreThanSixLetters = function(element, index, arr)
        return element.len() >= 6
    end function
    startsWithL = function(element, index, arr)
        return element.left(1) = "l"
    end function
    arr = ["light", "limit", "exuberant", "destruction"]
    result = m.assertEqual(m.testObject.findIndex(arr, moreThanSixLetters), 2)
    result += m.assertEqual(m.testObject.findIndex(arr, startsWithL), 0)
    result += m.assertEqual(m.testObject.findIndex([], moreThanSixLetters), -1)
    return result
end function

function TestCase__Array_GroupBy()
    arr = [
        { name: "asparagus", type: "vegetables", quantity: 5 },
        { name: "bananas", type: "fruit", quantity: 0 },
        { name: "goat", type: "meat", quantity: 23 },
        { name: "cherries", type: "fruit", quantity: 5 },
    ]
    expectedResultByType = {
        vegetables: [{ name: "asparagus", type: "vegetables", quantity: 5 }],
        fruit: [{ name: "bananas", type: "fruit", quantity: 0 }, { name: "cherries", type: "fruit", quantity: 5 }],
        meat: [{ name: "goat", type: "meat", quantity: 23 }]
    }
    expectedResultByQuantity = {
        "0": [{ name: "bananas", type: "fruit", quantity: 0 }],
        "5": [{ name: "asparagus", type: "vegetables", quantity: 5 }, { name: "cherries", type: "fruit", quantity: 5 }],
        "23": [{ name: "goat", type: "meat", quantity: 23 }]
    }
    result = m.assertEqual(m.testObject.groupBy(arr, "type"), expectedResultByType)
    result = m.assertEqual(m.testObject.groupBy(arr, "quantity"), expectedResultByQuantity)
    result = m.assertEqual(m.testObject.groupBy(arr, "key"), {})
    result = m.assertEqual(m.testObject.groupBy("array", "type"), invalid)
    result = m.assertEqual(m.testObject.groupBy([], "type"), {})
    return result
end function
