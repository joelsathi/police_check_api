import ballerina/io;
import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090");

// Before Suite Function

@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("I'm the before suite function!");
}

// Test function

@test:Config {}
function testServiceForCrimeRecordNotFound() {
    json payload = { "nic": "123456789V" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 2, "description": "Crime record not found" };
    test:assertEquals(result, expected);
}   

@test:Config {}
function testServiceForCrimeRecordFoundPending() {
    json payload = { "nic": "123456789032" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 1, "description": "Crime record found, Pending for approval" };
    test:assertEquals(result, expected);
}

@test:Config {}
function testServiceForCrimeRecordFoundDeclined() {
    json payload = { "nic": "123456789012" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 0, "description": "Crime record found, Declined" };
    test:assertEquals(result, expected);
}

// Negative test function

@test:Config {}
function testServiceWithInvalidNIC() returns error? {
    json payload = { "nic": "123456789" };
    http:Response response = check testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json errorPayload = check response.getJsonPayload();
    json expected = { "status": 4, "description": "Invalid NIC" };
    test:assertEquals(errorPayload, expected);
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("I'm the after suite function!");
}
