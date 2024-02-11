# Roku Libs

Libraries and utilities for BrightScript development.

This includes the following libraries and utilities:

-   [Google Analytics](#google-analytics) (deprecated - native support now exists through [Roku Analytics Component Library](https://developer.roku.com/en-gb/docs/developer-program/libraries/roku-analytics-component.md#google-analytics))
-   [HTTP Request](#http-request)
-   [Cache](#cache)
-   [Console](#console-utilities)
-   [Array](#array-utilities)
-   [String](#string-utilities)
-   [Math](#math-utilities)
-   [Registry](#registry-utilities)

## Getting Started

The libraries and utilities are bundled into a sample project which sole purpose is to run unit tests built with [Roku Unit Testing Framework](https://github.com/rokudev/unit-testing-framework).
Any file can and should be used separately as they do not have dependencies with each other.

### Makefile

The `Makefile` included provides a few simple rules to help with the app installation and testing.

From a terminal, you can first start by exporting the following variables

```bash
export DEVICEIP=<your_device_IP>
export ROKU=<your_dev_mode_user>
export ROKUPASS=<your_dev_mode_password>
```

To run the unit tests (output will be available on the [debug console](https://developer.roku.com/en-gb/docs/developer-program/debugging/debugging-channels.md))

```bash
make tests
```

## Description

### [Google Analytics](./source/libs/google-analytics.brs)

**Note: An [official library](https://developer.roku.com/en-gb/docs/developer-program/libraries/roku-analytics-component.md) now exists with support for Google Analytics, Omniture, Brightcove and Ooyala.**

This library provides tracking capabilities by sending data reports to Google Analytics using the [Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/reference).
Below are some example usages on how to use its different tracking functionalities.

To retrieve the GA global singleton object

```javascript
googleAnalytics = GoogleAnalyticsLib();
```

After having a reference to the GA global (we'll be using `googleAnalytics` in the following examples), initialise it by passing one or more Tracking IDs. This is required in order to enable reporting altogether, but only needs to be done **once**.

```javascript
googleAnalytics.init("UA-12345678-90")
//Or when passing multiple Tracking IDs in an array
googleAnalytics.init(["UA-12345678-90", ..., "UA-09876543-21"])
```

Sending tracking reports

```javascript
// Event tracking
googleAnalytics.trackEvent({ category: "application", action: "launch" });

// Screen Tracking
googleAnalytics.trackScreen({ name: "mainScreen" });

// E-Commerce tracking
googleAnalytics.trackTransaction({ id: "OD564", revenue: "10.00" });
googleAnalytics.trackItem({
    transactionId: "OD564",
    name: "Test01",
    price: "10.00",
    code: "TEST001",
    category: "vod",
});

// Timing tracking
googleAnalytics.trackTiming({
    category: "category",
    variable: "timing",
    time: "1000",
});

// Exception tracking
googleAnalytics.trackException({ description: "description", isFatal: "1" });
```

Adding custom parameters to all tracking reports

```javascript
googleAnalytics.setParams({ sr: "1280x800", ul: "en-gb" });
```

---

### [HTTP Request](./source/libs/http-request.brs)

A library that makes HTTP requests easier to deal with in BrightScript.

Below are some examples showing its different capabilities.

#### Request with 2s timeout and 3 retries

```javascript
request = HttpRequest({
    url: "https://postman-echo.com/delay/5",
    timeout: 2000,
    retries: 3,
});
response = request.send();
```

#### POST request with 'application/json' Content-Type

```javascript
request = HttpRequest({
    url: "https://postman-echo.com/post",
    method: "POST",
    headers: { "Content-Type": "application/json" },
    data: { user: "johndoe", password: "12345" },
});
response = request.send();
```

#### Abort on-going request

```javascript
request = HttpRequest({
    url: "https://postman-echo.com/delay/5",
});
request.send();
request.abort();
```

---

### [Cache](./source/utils/cache.brs)

The `Cache` utility creates a simple interface for caching data to [Roku's volatile storage](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/file-system.md). Uses `cachefs:` storage by default, but can be overwritten to `tmp:` storage.

```
CacheUtil(key [, options])
```

Accepts a `key` string and an optional `options` object as second parameter, which can have the following fields:

-   `algorithm`: `String` - hash algorithm for the key hashing, which will be used for the stored file name. **Defaults to `"sha1"`**.
-   `storage`: `String` - storage to be used by the cache. **Defaults to `"cachefs:/"`**.
-   `ttl`: `Integer` - time to live (in seconds) for the cache, after which the cache will expire. If set to `invalid` the cache will never expire. **Defaults to `5` seconds**.

#### Use Case

As a sample use case, `CacheUtil` can be used to cache the response of a given HTTP request. Assuming a request was made to `https://postman-echo.com/get` and `responseString` contains its response as a `string` value.

The response can be stored in cache as follows:

```javascript
cache = CacheUtil("https://postman-echo.com/get");
cache.put(responseString);
```

On a following request to the same URL the cached response could be retrieved before making a new request, given the TTL expiry hasn't been reached yet.

```javascript
cache = CacheUtil("https://postman-echo.com/get");
cachedValue = cache.get(); // Returns response string that was cached previously
```

---

### [Console Utilities](./source/utils/console.brs)

Small logging utility that enhances the built-in `print` debugging capabilities, with a syntax similiar to JavaScript's `console` object. It adds a timestamp to every log, provides group indentation, timers, counters, and different logging levels (`info`, `assert` and `error`).

Example usages:

```javascript
console = ConsoleUtil();
console.log("Hello World"); // [14:56:16:891] Hello World
console.time("Hello World"); // [14:56:16:891] Hello World: timer started
console.group();
console.log("Hello World"); // [14:56:16:892]     Hello World
console.count(); // [14:56:16:894]     default: 1
console.info("Hello World"); // [14:56:16:893]     [INFO] Hello World
console.group();
console.assert(false, "Hello World"); // [14:56:16:894]         [ASSERT] Hello World
console.count(); // [14:56:16:894]         default: 2
console.groupEnd();
console.assert(true, "Hello World");
console.error("Hello World"); // [14:56:16:895]     [ERROR] Hello World
console.count(); // [14:56:16:894]     default: 3
console.groupEnd();
console.timeEnd("Hello World"); // [14:56:16:895] Hello World: 4ms
```

---

### [Array Utilities](./source/utils/array.brs)

This utility expands the array functionalities provided by the built-in `roArray` type. It implements the following functions: `isArray`, `contains`, `indexOf`, `lastIndexOf`, `slice`, `fill`, `flat`, `map`, `reduce`, `filter`, `find`, `findIndex`, `every`, `some`, `groupBy`.

Example usages:

```javascript
arrUtil = ArrayUtil();
arr = [5, 2, 3, 2, 1];

arrUtil.isArray(arr); // true
arrUtil.contains(arr, 2); // true
arrUtil.indexOf(arr, 2); // 1
arrUtil.lastIndexOf(arr, 2); // 3
arrUtil.slice(arr, 1, 3); // [2,3,2]
arrUtil.fill(arr, 0, 1, 3); // [5,0,0,0,1]
arrUtil.flat([0, 1, 2, [3, 4]]); // [0,1,2,3,4]

// mapFunc = function(element, index, arr)
//     return element + 1
// end function
arrUtil.map(arr, mapFunc); // [6,3,4,3,2]

// reduceFunc = function(acc, element, index, arr)
//     return acc + element
// end function
arrUtil.reduce(arr, reduceFunc); // 13
arrUtil.reduce(arr, reduceFunc, 5); // 18

// filterFunc = function(element, index, arr)
//     return element > 2
// end function
arrUtil.filter(arr, filterFunc); // [5,3]

// testFunc = function(element, index, arr)
//     return element > 2
// end function
arrUtil.find(arr, testFunc); // 5
arrUtil.findIndex(arr, testFunc); // 0
arrUtil.every(arr, testFunc); // false
arrUtil.some(arr, testFunc); // true

groupArr = [
    { name: "asparagus", type: "vegetables" },
    { name: "bananas", type: "fruit" },
    { name: "cherries", type: "fruit" },
];
arrUtils.groupBy(groupArr, "type"); // { vegetables: [{ name: "asparagus", type: "vegetables" }], fruit: [{ name: "bananas", type: "fruit" }, { name: "cherries", type: "fruit" }] }
```

---

### [String Utilities](./source/utils/string.brs)

This utility expands the string functionalities provided by the built-in `String`/`roString` types. It implements the following functions: `isString`, `charAt`, `startsWith`, `endsWith`, `contains`, `indexOf`, `match`, `replace`, `truncate`, `repeat`, `padStart`, `padEnd`, `concat`, `toString`, `toMD5`, `toSHA1`, `toSHA256`, `toSHA512`.

Example usages:

```javascript
strUtil = StringUtil();
str = "AbraCadabra";

strUtil.isString(str); // true
strUtil.charAt(str, 1); // "b"
strUtil.startsWith(str, "Abra"); // true
strUtil.endsWith(str, "Cadabra"); // true
strUtil.contains(str, "bra"); // true
strUtil.indexOf(str, "ra"); // 2
strUtil.match(str, "(ab)(ra)", "i"); // ["Abra","Ab","ra"]
strUtil.replace(str, "Cad", "-"); // "Abra-abra"
strUtil.truncate(str, 4, "..."); // "Abra..."
strUtil.repeat(str, 2); // "AbraCadabraAbraCadabra"
strUtil.padStart(str, 15); // "    AbraCadabra"
strUtil.padEnd(str, 15); // "AbraCadabra    "
strUtil.concat(str, " Cadabra"); // "AbraCadabra Cadabra"
strUtil.toString(["1", 2, true]); // "[1,2,true]"
strUtil.toMD5(str); // "3aa51d002ab23a353b13df9ba059b4fc"
```

---

### [Math Utilities](./source/utils/string.brs)

This utility provides additional mathematical constants and functions for BrightScript. It implements the following functions: `isNumber`, `isInt`, `isFloat`, `isDouble`, `ceil`, `floor`, `round`, `min`, `max`, `power`.

Example usages:

```javascript
math = MathUtil();

math.isNumber(1.4); // true
math.ceil(1.4); // 2
math.floor(1.4); // 1
math.round(1.4); // 1
math.round(1.4159, 3); // 1.416
math.min(0, 3); // 0
math.max(0, 3); // 3
math.power(2, 8); // 256
math.E; // 2.718281828459
math.PI; // 3.1415926535898
```

---

### [Registry Utilities](./source/utils/registry.brs)

This utility makes it easier to deal with `roRegistry` and `roRegistrySection` objects by simplifiyng all registry functions. It implements the following functions: `read`, `write`, `delete`, `readSection`, `deleteSection`, `getSections`, `clear`.

Example usages:

```javascript
registry = RegistryUtil();

registry.write("myKey", "myValue", "mySection"); // Replaces the value of the specified key for a given section
registry.read("myKey", "mySection"); // Reads and returns the value of the specified key from a given section
registry.delete("myKey", "mySection"); // Deletes the specified key from a given section
registry.readSection("mySection"); // Reads and return all key values from a given section
registry.deleteSection("mySection"); // Deletes all key values from a specified section
registry.getSections(); // Returns all sections in the registry
registry.clear(); // Deletes all sections from the registry
```

## Contributing

Feel free to submit any pull request or issue to contribute to this project. Suggestions for new utilities or features are also welcomed.

## Authors

-   [juliomalves](https://github.com/juliomalves) - Initial work & maintainer

## License

This project is licensed under the [MIT License](./LICENSE).
