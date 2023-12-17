import ballerinax/mongodb;

configurable string username = ?;
configurable string password = ?;
configurable string collectionName = ?;
configurable string databaseName = ?;

final mongodb:Client mongoClient = checkpanic new ({connection: {url: string `mongodb+srv://${username}:${password}@cluster0.dkdiej3.mongodb.net/?retryWrites=true&w=majority`}});
