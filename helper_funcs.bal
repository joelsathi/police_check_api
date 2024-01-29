import ballerina/http;

# Validate the NIC with regex
# 
# + nic - NIC as a string
# + return - boolean
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

# Validate the crime severity
# 
# + crime_severity - crime severity as an integer
# + return - boolean
function validateCrimeSeverity(int crime_severity) returns boolean {
    boolean isValid = false;
    if (crime_severity >= 1 && crime_severity <= 10) {
        isValid = true;
    }
    return isValid;
}

# Validate the data
# 
# + user_det - CrimeRecord object
# + return - string, a message containing the error
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

# Add a crime record in the database
# 
# + user_det - CrimeRecord object
# + caller - http:Caller object
# + return - error
function addCrimeRecord(CrimeRecord user_det, http:Caller caller) returns error? {
    http:Response response = new;

    string message = validateData(user_det);

    if (message != "") {
        response.statusCode = 400;
        response.setPayload({status:"Error",description: message});
        check caller->respond(response);
        return;
    }

    error? res = checkpanic mongoClient->insert(user_det, collectionName, databaseName);

    if res is error {
        response.statusCode = 500;
        response.setPayload({status:"Error",description: "Error while adding crime record"});
    }
    else{
        response.statusCode = 201;
        response.setPayload({status:"Success",description: "Crime record added successfully"});
    }

    check caller->respond(response);
    return;
}

# Get a crime record from the database  
# Status codes and details are as follows
# 0 - Declined
# 1 - Pending for approval
# 2 - Not found
# 3 - More Info needed
# 4 - Invalid Data
# 
# + nic - NIC as a string
# + caller - http:Caller object, it will contain the JSON response
# + return - error
function getCrimeRecord(string nic, http:Caller caller) returns error? {
    http:Response response = new;

    boolean isValid = validateNic(nic);

    if (!isValid) {
        response.statusCode = 201;
        response.setPayload({status:4,description: "Invalid NIC"});
        check caller->respond(response);
        return;
    }

    int crime_severity = 0;
    map<json> filter = {nic: nic};
    stream<MongoCrimeRecord, error?> result = check mongoClient->find(collectionName, databaseName, filter=filter);
    check result.forEach(function (MongoCrimeRecord data) {
        crime_severity = crime_severity + data.crime_severity;
    });

    int|error count = check mongoClient->countDocuments(collectionName, databaseName, filter=filter);

    if count is error{
        response.statusCode = 500;
        response.setPayload({status:"Error",description: "Error while getting crime record"});
    }
    else{
        if (count == 0) {
            response.statusCode = 201;
            response.setPayload({status:2,description: "Crime record not found"});
        }
        else{
            float avg_crime_severity = <float>(crime_severity / count);
            if (avg_crime_severity < 5.1){
                response.statusCode = 201;
                response.setPayload({status:1,description: "Crime record found, Pending for approval"});
            }
            else{
                response.statusCode = 201;
                response.setPayload({status:0,description: "Crime record found, Declined"});
            }
        }
    }

    check caller->respond(response);
}