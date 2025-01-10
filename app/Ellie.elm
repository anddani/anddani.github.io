module Ellie exposing (outputTabElmCss)

import Html exposing (Html)
import Html.Attributes as Attr


outputTabElmCss : String -> Html msg
outputTabElmCss ellieId =
    Html.iframe
        [ Attr.src <| "https://ellie-app.com/embed/" ++ ellieId ++ "?panel=output"
        , Attr.style "width" "100%"
        , Attr.style "height" "400px"
        , Attr.style "border" "0"
        , Attr.style "overflow" "hidden"
        , Attr.attribute "sandbox" "allow-modals allow-forms allow-popups allow-scripts allow-same-origin"
        ]
        []
