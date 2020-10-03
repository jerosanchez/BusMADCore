# BusMADCore - Access Token Feature

## BDD Specs

### Story: User needs to perform any authenticated operation

#### Narrative #1

> As an online user
> I want the app to automatically authenticate on my behalf whenever required
> So I don't need to signup or signin to the service myself

Scenarios (acceptance criteria):

```
Given the user has connectivity
  And the cache is empty
 When the user requests any operation that requires to be authenticated 
 Then the app should deliver a new access token
  And replace the cache with the new access token

Given the user has connectivity
  And there's an access token cached
  And the access token has a future expiration date
 When the user requests any operation that requires to be authenticated 
 Then the app should deliver the access token saved

Given the user has connectivity
  And there's an access token cached
  And the access token has a future expiration date
  And the today's calls count exceeds daily calls limit 
 When the user requests any operation that requires to be authenticated 
 Then the app should display an error message

Given the user has connectivity
  And there's an access token cached
  And the access token expires now or has already expired
 When the user requests any operation that requires to be authenticated 
 Then the app should deliver a refreshed access token
  And replace the cache with the new access token
```

## Use Cases

### Load Access Token From Remote Use Case

#### Data
- URL
- ClientId
- PassKey

#### Primary course (happy path):
1. Execute "Load" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates session information from valid data.
5. System delivers session information.

#### No connectivity – error course (sad path):
1. System delivers error.

#### Invalid data – error course (sad path):
1. System delivers error.

#### Invalid credentials - error course (sad path):
1. System delivers error.

#### Wrong request - error course (sad path):
1. System delivers error.

#### Daily calls limit reached - error course (sad path):
1. System delivers error.


### Load Access Token From Cache Use Case

#### Primary course (happy path):
1. Execute "Load" command with above data.
2. System retrieves access token from cache.
3. System validates access token has not expired.
4. System creates access token fro cached data.
5. System delivers access token.

#### Retrieval error – error course (sad path):
1. System delivers error.

#### Expired access token – error course (sad path):
1. System delivers error.

#### Empty cache - error course (sad path):
1. System delivers error.


### Validate Access Token In Cache Use Case

#### Primary course (happy path):
1. Execute "Validate Cache" command with above data.
2. System retrieves access token from cache.
3. System validates access token has a future expiration date.

#### Retrieval error – error course (sad path):
1. System delivers error.

#### Access token expired – error course (sad path):
1. System delivers error.


### Cache Access Token Use Case

#### Data
- Access Token

#### Primary course (happy path):
1. Execute "Save Access Token" command with above data.
2. System deletes old cache data.
3. System encodes access token.
4. System saves new cache data.
5. System delivers success message.

#### Deleting error – error course (sad path):
1. System delivers error.

#### Saving error – error course (sad path):
1. System delivers error.


## Flowchart

Not available.

## Architecture

Not available.

## Model Specs

### Access Token

| Property              | Type          |
|-----------------------|---------------|
| `token`               | `UUID`        |
| `expirationTime`      | `Date`        |
| `dailyCallsLimit`     | `Int`         |
| `todayCallsCount`     | `Int`         |

## Payload contract

```
GET https://openapi.emtmadrid.es/v2/mobilitylabs/user/login/

Headers:
"X-ClientId" -> client ID provided by the service (UUID)
"passKey" -> API key provided by the service
```

On success:

```
200 RESPONSE

{
    "code": "01",
    "description": "a description",
    "datetime": "2020-09-20T14:17:06.762756",
    "data": [
        {
            "nameApp": "app name",
            "updatedAt": "2020-06-18T19:17:23.017000",
            "userName": "user name",
            "lastUpdate": {
                "$date": 1600601707349
            },
            "idUser": "an UUID",
            "priv": "U",
            "tokenSecExpiration": 86400,
            "email": "mailbox@server.com",
            "tokenDteExpiration": {
                "$date": 1600695307349
            },
            "flagAdvise": false,
            "accessToken": "an UUID",
            "apiCounter": {
                "current": 10,
                "dailyUse": 250000,
                "owner": 0,
                "licenceUse": "Please mention EMT Madrid MobilityLabs as data source. Thank you and enjoy!"
            },
            "username": "user name"
        }
    ]
}
```

On invalid credentials:

```
200 RESPONSE

{
    "code": "80",
    "description": "a description"
}
```

On wrong request:

```
200 RESPONSE

{
    "code": "90",
    "description": "a description",
    "data": []
}
```

For more information you can see the [EMT Madrid API documentation](https://apidocs.emtmadrid.es/#api-Block_1_User_identity-login).
