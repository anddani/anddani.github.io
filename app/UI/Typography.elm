module UI.Typography exposing (h1, h2, h3, h4, h5, h6, p)

import Html exposing (Html)
import Html.Attributes exposing (class)


h1 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h1 styles children =
    Html.h1 (class "font-bold text-5xl" :: styles) children


h2 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h2 styles children =
    Html.h2 (class "font-bold text-4xl" :: styles) children


h3 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h3 styles children =
    Html.h3 (class "font-bold text-3xl" :: styles) children


h4 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h4 styles children =
    Html.h4 (class "font-bold text-2xl" :: styles) children


h5 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h5 styles children =
    Html.h5 (class "font-bold text-xl" :: styles) children


h6 : List (Html.Attribute msg) -> List (Html msg) -> Html msg
h6 styles children =
    Html.h6 (class "font-bold text-lg" :: styles) children


p : List (Html.Attribute msg) -> List (Html msg) -> Html msg
p styles children =
    Html.p (class "text-base" :: styles) children
