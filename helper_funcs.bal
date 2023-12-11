import ballerinax/mongodb;
import ballerina/http;
// import ballerina/io;

public type CrimeRecord record {|
    string firstName;
    string lastName;
    string middleName?;
    string city;
    string nic;
    string crime_cat;
    int crime_severity;           // Define a severity score between 1-10
    string comments?;
|};

public type NIC_Record record {
    string nic;
};

configurable string username = ?;
configurable string password = ?;
configurable string collectionName = ?;
configurable string databaseName = ?;

final mongodb:Client mongoClient = checkpanic new ({connection: {url: string `mongodb+srv://${username}:${password}@cluster0.dkdiej3.mongodb.net/?retryWrites=true&w=majority`}});

function validateNic(string nic) returns boolean {
    boolean isValid = false;
    string:RegExp nicRegex = re`^[0-9]{9}[vVxX]$`;
    string:RegExp nicRegex2 = re`^[0-9]{12}$`;

    if (nic.matches(nicRegex)) {
        isValid = true;
    }
    else if (nic.matches(nicRegex2)) {
        isValid = true;
    }
    return isValid;
}

function validateCrimeSeverity(int crime_severity) returns boolean {
    boolean isValid = false;
    if (crime_severity >= 1 && crime_severity <= 10) {
        isValid = true;
    }
    return isValid;
}

function validateData(CrimeRecord user_det) returns string {
    string message = "";

    if (!validateNic(user_det.nic)) {
        message = "Invalid NIC";
    }

    if (!validateCrimeSeverity(user_det.crime_severity)) {
        message = "Invalid crime severity";
    }

    return message;
}

function addCrimeRecord(CrimeRecord user_det, http:Caller caller) returns error? {
    http:Response response = new;

    string message = validateData(user_det);

    if (message != "") {
        response.statusCode = 201;
        response.setPayload({status:"Error",description: message});
        check caller->respond(response);
        return;
    }

    error? res = checkpanic mongoClient->insert(user_det, collectionName, databaseName);

    if res is error {
        response.statusCode = 500;
        response.setPayload({status:"Error",description: "Error while adding crime record"});
        // io:print("Error while adding crime record");
    }
    else{
        response.statusCode = 201;
        response.setPayload({status:"Success",description: "Crime record added successfully"});
        // io:print("Crime record added successfully");
    }

    check caller->respond(response);
    return;
}

function getCrimeRecord(string nic, http:Caller caller) returns error? {
    http:Response response = new;

    // io:print("NIC: " + nic);
    boolean isValid = validateNic(nic);
    // io:print("isValid: " + isValid.toBalString());

    if (!isValid) {
        response.statusCode = 201;
        response.setPayload({status:"Error",description: "Invalid NIC"});
        check caller->respond(response);
        // io:print("Invalid NIC");
        return;
    }

    int|error count = check mongoClient->countDocuments(collectionName, databaseName, {nic: nic});

    if count is error{
        response.statusCode = 500;
        response.setPayload({status:"Error",description: "Error while getting crime record"});
        // io:print("Error while getting crime record");
    }
    else{
        if (count == 0) {
            response.statusCode = 201;
            response.setPayload({status:"Approve",description: "Crime record not found"});
            // io:print("Crime record not found");
        }
        else {
            response.statusCode = 201;
            response.setPayload({status:"Reject",description: "Crime record found"});
            // io:print("Crime record found");
        }
    }

    check caller->respond(response);
}