# BusMADCore - Nearest Stops Feature

## BDD Specs

### Story: Customer requests to see the nearest stops

#### Narrative #1

> As an online customer
I want the app to load the nearest stops to my current location
So I can choose a stop to see detailed information

Scenarios (acceptance criteria):

```
Given the customer has connectivity
When the customer request to see the nearest stops
Then the app should display a list of the nearest stops to the customer's current location within a certain radius
```

## Use Cases

### Load Nearest Stops From Remote Use Case

#### Data
- URL
- Latitude
- Longitude
- Radius

#### Primary course (happy path):
1. Execute "Load Nearest Stops" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates nearest stops from valid data.
5. System delivers nearest stops.

#### Session expired - error course (sad path):
1. System delivers error.

#### Invalid data – error course (sad path):
1. System delivers error.

#### No connectivity – error course (sad path):
1. System delivers error.

#### Wrong request - error course (sad path):
1. System delivers error.
2. System emmits an analytics error event.

## Flowchart

Not available

## Architecture

Not available

## Model Specs

### Nearest Stop

| Property      | Type          |
|---------------|---------------|
| `stopId`      | `Int`         |
| `latitude`    | `Double`      |
| `longitude`   | `Double`      |
| `name`        | `String`      |
| `address`     | `String`      |
| `distance`    | `Int`         |
| `lines`       | `[NSL]`       | An array of Nearest Stop Line
 
### Nearest Stop Line

| Property      | Type      |
|---------------|-----------|
| `lineId`      | `Int`     |
| `origin`      | `String`  |
| `destination` | `String`  |

### Payload contract

```
GET https://openapi.emtmadrid.es/v2/transport/busemtmad/stops/arroundxy/<longitude>/<latitude>/<radius>/

- <longitude> expressed in decimal units (e.g. -3.640491)
- <latitude> expressed in decimal units (e.g. 40.385558)
- <radius> expressed in meters from current user's location (.e.g. 200)
```

On success:

```
200 RESPONSE

{
    "code": "00",
    "description": "Data recovered OK (lapsed: 89 millsecs)",
    "data": [
        {
            "stopId": 3343,
            "geometry": {
                "type": "Point",
                "coordinates": [
                    -3.64104303073248,
                    40.3870110914798
                ]
            },
            "stopName": "Metro Miguel Hernández",
            "address": "Av. Rafael Alberti, 22",
            "metersToPoint": 168,
            "lines": [
                {
                    "line": "144",
                    "label": "144",
                    "nameA": "PAVONES",
                    "nameB": "ENTREVIAS",
                    "metersFromHeader": 2212,
                    "to": "B"
                }
            ]
        },
        
		...
    ]
```

On session expired:

```
200 RESPONSE

{
    "code": "80",
    "description": "Error, token XXX not found in cache"
}
```

On invalid request data:

```
200 RESPONSE

{
    "code": "90",
    "description": "XXX",
    "data": []
}
```
