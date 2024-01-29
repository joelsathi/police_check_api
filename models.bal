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

public type MongoCrimeRecord record{|
    json _id;
    *CrimeRecord;
|};
