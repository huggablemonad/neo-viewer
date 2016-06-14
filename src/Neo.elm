module Neo exposing (Neo, getToday)

{-| Retrieve a list of Near Earth Objects for today.

@docs Neo, getToday
-}

import Http
import Json.Decode as Json exposing ((:=))
import Json.Decode.Pipeline as Json
import Task


{-| Details of a Near Earth Object.

The minimum and maximum diameters are in meters, and the miss distance is in
lunars.
-}
type alias Neo =
  { id : String -- SPK-ID.
  , name : String  -- IAU name
  , url : String  -- Link to JPL Small-Body Database Browser.
  , minDiameter : Float  -- In meters.
  , maxDiameter : Float  -- In meters.
  , pha : Bool  -- Potentially hazardous asteroid.
  , missDistance : String -- Lunar distance.
  }


{-| Decode a list of Near Earth Objects. Fails if the number of elements
specified in the JSON is `0`. -}
decodeNeos : Int -> Json.Decoder (List (String, List Neo))
decodeNeos numElements =
  if numElements > 0 then
    "near_earth_objects" := Json.keyValuePairs (Json.list decodeNeo)

  else
    Json.fail "No data found."


{-| Decode a Near Earth Object to `Neo`. -}
decodeNeo : Json.Decoder Neo
decodeNeo =
  Json.decode Neo
    |> Json.required "neo_reference_id" Json.string
    |> Json.required "name" Json.string
    |> Json.required "nasa_jpl_url" Json.string
    |> (let lo = ["estimated_diameter", "meters", "estimated_diameter_min"]
        in Json.requiredAt lo Json.float)
    |> (let hi = ["estimated_diameter", "meters", "estimated_diameter_max"]
        in Json.requiredAt hi Json.float)
    |> Json.required "is_potentially_hazardous_asteroid" Json.bool
    |> Json.custom decodeMissDistance


{-| Decode the lunar miss distance. -}
decodeMissDistance : Json.Decoder String
decodeMissDistance =
  let lunar = Json.at ["miss_distance", "lunar"] Json.string
  in "close_approach_data" := Json.tuple1 identity lunar


{-| Return the `Task` for retrieving the list of Near Earth Objects for today.
-}
getToday : Task.Task Http.Error (List (String, List Neo))
getToday =
  let url = "https://api.nasa.gov/neo/rest/v1/feed/today?api_key=DEMO_KEY"
      decoder = "element_count" := Json.int `Json.andThen` decodeNeos
  in Http.get decoder url
