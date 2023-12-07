import ballerina/http;

configurable int port = ?;

service / on new http:Listener(port) {

    // This function responds with `string` value `Hello, World!` to HTTP GET requests.
    resource function get greeting() returns string {
        return "Hello, World!";
    }

    resource function post criminal_records(@http:Payload CrimeRecord crime_record, http:Caller caller) returns error? {
        return addCrimeRecord(crime_record, caller);
    }

    resource function post check_status(@http:Payload NIC_Record nic_record,http:Caller caller) returns error? {
        return getCrimeRecord(nic_record.nic, caller);  
    }
}
