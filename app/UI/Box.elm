module UI.Box exposing (box)

import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes exposing (class, css)
import Tailwind.Utilities exposing (..)


box : String -> List (Html msg) -> Html msg
box style children =
    Html.div
        [ class <| "rounded-lg border shadow-sm p-5" ++ " " ++ style ]
        children
