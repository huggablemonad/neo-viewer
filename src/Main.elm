module Main exposing (main)

{-| # Near Earth Object Viewer
------------------------------
This app shows a list of Near Earth Objects for today.

1.  **User Story:** I can see a list of Near Earth Objects for today.

2.  **User Story:** I can click on an asteroid ID and be sent to a NASA page
    with more details about it.

3.  **User Story:** I can see an icon or color that indicates a potentially
    hazardous asteroid.

<https://huggablemonad.github.io/neo-viewer/>

# Main
@docs main

-}

import Html.App
import Viewer


{-| Main entry point. -}
main : Program Never
main =
  Html.App.program
    { init = Viewer.init
    , view = Viewer.view
    , update = Viewer.update
    , subscriptions = Viewer.subscriptions
    }
