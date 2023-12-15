import ballerina/http;
import ballerina/io;
import ballerina/test;

@test:BeforeSuite
function before_add_crime_records() {
    io:println("Starting the add crime records test suite");
}

@test:Config {}
function testServiceWithValidPayload() {
    json payload = {
        "firstName": "mj",
        "lastName": "joker",
        "city": "Houston",
        "nic": "123456789012",
        "crime_cat": "white-collar crime",
        "crime_severity": 6
    };
    http:Response response = checkpanic testClient->post("/criminal_records", payload);
    test:assertEquals(response.statusCode, 201, "Status code should be 201");
    json responsePayload = checkpanic response.getJsonPayload();
    json expected = {status:"Success",description: "Crime record added successfully"};
    test:assertEquals(responsePayload, expected, "Response payload mismatched");
}

@test:Config {}
function testWithInvalidNIC(){
    json payload = {
        "firstName": "mj",
        "lastName": "joker",
        "city": "Houston",
        "nic": "1234567890123",
        "crime_cat": "white-collar crime",
        "crime_severity": 6
    };
    http:Response response = checkpanic testClient->post("/criminal_records", payload);
    test:assertEquals(response.statusCode, 400, "Status code should be 400");
    json responsePayload = checkpanic response.getJsonPayload();
    json expected = {status:"Error",description: "Invalid NIC"};
    test:assertEquals(responsePayload, expected, "Response payload mismatched");
}

@test:Config {}
function testWithInvalidCrimeSeverity(){
    json payload = {
        "firstName": "mj",
        "lastName": "joker",
        "city": "Houston",
        "nic": "123456789012",
        "crime_cat": "white-collar crime",
        "crime_severity": 20
    };
    http:Response response = checkpanic testClient->post("/criminal_records", payload);
    test:assertEquals(response.statusCode, 400, "Status code should be 400");
    json responsePayload = checkpanic response.getJsonPayload();
    json expected = {status:"Error",description: "Invalid crime severity"};
    test:assertEquals(responsePayload, expected, "Response payload mismatched");
}

@test:AfterSuite
function after_add_crime_records() {
    io:println("Completed the add crime records test suite");
}

