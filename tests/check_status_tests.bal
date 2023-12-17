import ballerina/io;
import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090/police_check");

@test:BeforeGroups { value:["check_status"] }
function before_check_status_test() {
    io:println("Starting the check status tests");
}

// Test function
@test:Config { groups: ["check_status"] }
function testServiceForCrimeRecordNotFound() {
    json payload = { "nic": "123456789V" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 2, "description": "Crime record not found" };
    test:assertEquals(result, expected);
}   

@test:Config { groups: ["check_status"] }
function testServiceForCrimeRecordFoundPending() {
    json payload = { "nic": "123456789032" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 1, "description": "Crime record found, Pending for approval" };
    test:assertEquals(result, expected);
}

@test:Config { groups: ["check_status"] }
function testServiceForCrimeRecordFoundDeclined() {
    json payload = { "nic": "123456789012" };
    http:Response response = checkpanic testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json result = checkpanic response.getJsonPayload();
    json expected = { "status": 0, "description": "Crime record found, Declined" };
    test:assertEquals(result, expected);
}

// Negative test function

@test:Config { groups: ["check_status"] }
function testServiceWithInvalidNIC() returns error? {
    json payload = { "nic": "123456789" };
    http:Response response = check testClient->post("/check_status", payload);
    test:assertEquals(response.statusCode, 201);
    json errorPayload = check response.getJsonPayload();
    json expected = { "status": 4, "description": "Invalid NIC" };
    test:assertEquals(errorPayload, expected);
}

@test:AfterGroups { value:["check_status"] }
function after_check_status_test() {
    io:println("Completed the check status tests");
}
