module UI.Typography exposing (h1, h2, h3, h4, p)

import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (class, css)
import Tailwind.Breakpoints exposing (..)
import Tailwind.Theme exposing (..)
import Tailwind.Utilities exposing (..)


h1 : String -> Html msg
h1 text =
    Html.h1
        [ class "font-bold text-3xl md:text-4xl" ]
        [ Html.text text ]


h2 : String -> Html msg
h2 text =
    Html.h2 [ class "font-bold text-2xl" ] [ Html.text text ]


h3 : String -> Html msg
h3 text =
    Html.h3 [ class "font-bold text-xl" ] [ Html.text text ]


h4 : String -> String -> Html msg
h4 style text =
    Html.h4 [ class <| "font-bold text-lg" ++ " " ++ style ] [ Html.text text ]


p : String -> String -> Html msg
p style text =
    Html.p [ class <| "text-base" ++ " " ++ style ] [ Html.text text ]
