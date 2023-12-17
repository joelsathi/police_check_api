import ballerina/http;

service /police_check on new http:Listener(9090) {

    # Add a new crime record
    # 
    # + crime_record - Crime record to be added
    # + caller - The caller of the service
    # + return - Error if any
    resource function post criminal_records(@http:Payload CrimeRecord crime_record, http:Caller caller) returns error? {
        return addCrimeRecord(crime_record, caller);
    }

    # Get a crime record
    # 
    # + nic_record - NIC record with the NIC number
    # + caller - The caller of the service
    # + return - Error if any
    resource function post check_status(@http:Payload NIC_Record nic_record,http:Caller caller) returns error? {
        return getCrimeRecord(nic_record.nic, caller);  
    }
}
