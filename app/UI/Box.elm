module UI.Box exposing (box)

import Html exposing (Html)
import Html.Attributes exposing (class)


box : String -> List (Html msg) -> Html msg
box style children =
    Html.div
        [ class <| "rounded-lg border shadow-sm p-5" ++ " " ++ style ]
        children
