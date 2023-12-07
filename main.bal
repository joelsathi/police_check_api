import ballerina/http;

service / on new http:Listener(9090) {

    // This function responds with `string` value `Hello, World!` to HTTP GET requests.
    resource function get greeting() returns string {
        return "Hello, World!";
    }

    resource function post criminal_records(@http:Payload CrimeRecord crime_record, http:Caller caller) returns error? {
        return addCrimeRecord(crime_record, caller);
    }

    resource function get check_status/[string nic](http:Caller caller) returns error? {
        return getCrimeRecord(nic, caller);
    }
}
