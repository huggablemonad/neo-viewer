module Viewer exposing
  ( Model, init
  , Msg, update
  , view
  , subscriptions
  )

{-| This module contains functions to retrieve and display a list of Near Earth
Objects for today.

# Model
@docs Model, init

# Update
@docs Msg, update

# View
@docs view

# Subscriptions
@docs subscriptions

-}

import Html
import Html.Attributes as Html
import Http
import List
import Maybe
import Neo
import Result
import String
import Task


{-| Application state. -}
type alias Model =
  { date : String
  , neos : List Neo.Neo
  }


{-| Initialize the application. -}
init : (Model, Cmd Msg)
init =
  ( Model "Loading..." []
  , getNeosToday
  )


{-| Messages for updating the application state. -}
type Msg
  = FetchSucceed (List (String, List Neo.Neo))
  | FetchFail Http.Error


{-| Update the application state. -}
update : Msg -> Model -> (Model, Cmd msg)
update msg model =
  case msg of
    FetchSucceed neosToday ->
      let data = Maybe.withDefault ("", []) <| List.head neosToday
      in (Model (fst data) (snd data), Cmd.none)

    FetchFail _ ->
      (model, Cmd.none)


{-| View the application state as HTML. -}
view : Model -> Html.Html Msg
view model =
  Html.div
    []
    [ Html.h1 [] [ Html.text "Near Earth Object Viewer" ]
    , Html.p
        [ Html.classList
            [ ("date", True)
            , ("lead", True)
            ]
        ]
        [ Html.text model.date ]
    , Html.div [] <| List.map neoItem model.neos
    ]


{-| Return the HTML for a Near Earth Object item. -}
neoItem : Neo.Neo -> Html.Html Msg
neoItem neo =
  Html.div
    [ Html.classList
        [ ("bg-success", not neo.pha)
        , ("bg-danger", neo.pha)
        , ("neo-item", True)
        ]
    ]
    [ Html.p
        []
        [ Html.span [ Html.class "h3" ]
            [ Html.text neo.name
            , Html.br [] []
            , Html.a [ Html.href neo.url ] [ Html.text neo.id ]
            ]
        ]
     , Html.p
         [ Html.class "h4" ]
         [ Html.text "Estimated diameter (in meters): "
         , Html.text << toString << round <| neo.minDiameter
         , Html.text " - "
         , Html.text << toString << round <| neo.maxDiameter
         , Html.br [] []
         , Html.text "Miss distance (in lunars): "
         , Html.text
             << toString
             << round
             << Result.withDefault 0
             << String.toFloat
             <| neo.missDistance
         , Html.br [] []
         , Html.text "Potentially hazardous: "
         , Html.text <| if neo.pha then "Yes" else "No"
         ]
     ]


{-| Return subscriptions to event sources. -}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


{-| Return the Near Earth Objects for today. -}
getNeosToday : Cmd Msg
getNeosToday =
  Task.perform FetchFail FetchSucceed Neo.getToday
