module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Article
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes exposing (class, css, href)
import Pages.Url
import PagesMsg exposing (PagesMsg)
import Route exposing (Route)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw exposing (..)
import UI.ArticleBox exposing (articleBox)
import UI.Box exposing (box)
import UI.Icons as Icons
import UI.Typography as Typography
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
    { title = "André Danielsson"
    , body =
        [ header
        , articleList app.data.articles
        ]
    }


iconRow : Html msg
iconRow =
    Html.div [ class "flex flex-row gap-4 pt-3" ]
        [ socialLink "https://github.com/anddani" Icons.github
        , socialLink "https://www.linkedin.com/in/andr%C3%A9-danielsson-143286bb/" Icons.linkedin
        , socialLink "https://letterboxd.com/anddani" Icons.letterboxd
        ]


socialLink : String -> Html msg -> Html msg
socialLink url icon =
    Html.a
        [ href url
        , class "hover:opacity-50 transition-all duration-200"
        ]
        [ icon ]


header : Html msg
header =
    Html.header
        [ class "pt-12" ]
        [ box ""
            [ Typography.h2 "André Danielsson"
            , Html.p
                [ css
                    [ Tw.pt_1
                    ]
                ]
                [ Html.text "Software developer" ]
            , iconRow
            ]
        ]


articleList : List ( Route, Article.ArticleMetadata ) -> Html msg
articleList articles =
    Html.div [ css [ flex, flex_col, gap_6, pt_10 ] ]
        [ Typography.h2 "Articles"
        , Html.ul
            [ css [ flex, flex_col, gap_3 ] ]
            (List.map articleBox articles)
        ]
