module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Article
import BackendTask exposing (BackendTask)
import Date
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attr exposing (css)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route exposing (Route)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { articles : List ( Route, Article.ArticleMetadata )
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.map (\articles -> { articles = articles }) Article.articles


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = [ "images", "icon-png.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Personal website"
        , locale = Nothing
        , title = "Andre Danielsson"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = "elm-pages is running"
    , body =
        [ Html.h1 [ css [ Tw.text_color Tw.gray_600 ] ] [ Html.text "elm-pages is up and running!" ]
        , Html.ul
            []
            (app.data.articles
                |> List.map
                    (\( route_, article ) ->
                        Html.li
                            []
                            [ Html.text (article.title ++ " " ++ Date.toIsoString article.published)
                            , link route_ [] [ Html.text "Read more" ]
                            ]
                    )
            )
        ]
    }


link : Route -> List (Attribute msg) -> List (Html msg) -> Html msg
link route_ attrs children =
    Route.toLink
        (\anchorAttrs ->
            Html.a
                (List.map Attr.fromUnstyled anchorAttrs ++ attrs)
                children
        )
        route_
