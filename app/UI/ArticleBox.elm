module UI.ArticleBox exposing (articleBox)

import Article
import Date exposing (toIsoString)
import Html exposing (Attribute, Html)
import Html.Attributes exposing (class)
import Route exposing (Route)
import UI.Box exposing (box)
import UI.Typography as Typography


articleBox : ( Route, Article.ArticleMetadata ) -> Html msg
articleBox ( route_, article ) =
    Html.li []
        [ link route_
            []
            [ box "group hover:translate-y-[-3px] hover:shadow-md transition-all"
                [ Html.div
                    [ class "flex flex-col gap-1" ]
                    [ Typography.h5 [ class "group-hover:underline" ] [ Html.text article.title ]
                    , Typography.p [] [ Html.text article.description ]
                    , Html.text <| toIsoString article.published
                    ]
                ]
            ]
        ]


link : Route -> List (Attribute msg) -> List (Html msg) -> Html msg
link route_ attrs children =
    Route.toLink
        (\anchorAttrs ->
            Html.a
                (anchorAttrs ++ attrs)
                children
        )
        route_
