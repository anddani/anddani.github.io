module TailwindMarkdownRenderer exposing (renderer)

import Ellie
import Html
import Html.Attributes as Attr exposing (class)
import Markdown.Block as Block
import Markdown.Html
import Markdown.Renderer
import Oembed
import SyntaxHighlight
import UI.Typography as Typography


renderer : Markdown.Renderer.Renderer (Html.Html msg)
renderer =
    { heading = heading
    , paragraph = Typography.p [ class "pb-4" ]
    , thematicBreak = Html.hr [] []
    , text = Html.text
    , strong = \content -> Html.strong [ class "font-bold" ] content
    , emphasis = \content -> Html.em [ class "italic" ] content
    , blockQuote = Html.blockquote []
    , codeSpan =
        \content ->
            Html.code [ class "font-semibold font-medium !text-[#E20000]" ] [ Html.text content ]
    , link =
        \{ destination } body ->
            Html.a
                [ Attr.href destination
                , class "underline"
                ]
                body
    , hardLineBreak = Html.br [] []
    , image =
        \image ->
            case image.title of
                Just _ ->
                    Html.img [ Attr.src image.src, Attr.alt image.alt ] []

                Nothing ->
                    Html.img [ Attr.src image.src, Attr.alt image.alt ] []
    , unorderedList =
        \items ->
            Html.ul []
                (items
                    |> List.map
                        (\item ->
                            case item of
                                Block.ListItem task children ->
                                    let
                                        checkbox =
                                            case task of
                                                Block.NoTask ->
                                                    Html.text ""

                                                Block.IncompleteTask ->
                                                    Html.input
                                                        [ Attr.disabled True
                                                        , Attr.checked False
                                                        , Attr.type_ "checkbox"
                                                        ]
                                                        []

                                                Block.CompletedTask ->
                                                    Html.input
                                                        [ Attr.disabled True
                                                        , Attr.checked True
                                                        , Attr.type_ "checkbox"
                                                        ]
                                                        []
                                    in
                                    Html.li [] (checkbox :: children)
                        )
                )
    , orderedList =
        \startingIndex items ->
            Html.ol
                (case startingIndex of
                    1 ->
                        [ Attr.start startingIndex ]

                    _ ->
                        []
                )
                (items
                    |> List.map
                        (\itemBlocks ->
                            Html.li []
                                itemBlocks
                        )
                )
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "oembed"
                (\url _ ->
                    Oembed.view [] Nothing url
                        |> Maybe.withDefault (Html.div [] [])
                )
                |> Markdown.Html.withAttribute "url"
            , Markdown.Html.tag "ellie-output"
                (\ellieId _ ->
                    Ellie.outputTabElmCss ellieId
                )
                |> Markdown.Html.withAttribute "id"
            ]
    , codeBlock = codeBlock
    , table = Html.table []
    , tableHeader = Html.thead []
    , tableBody = Html.tbody []
    , tableRow = Html.tr []
    , strikethrough =
        \children -> Html.del [] children
    , tableHeaderCell =
        \maybeAlignment ->
            let
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map Attr.align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            Html.th attrs
    , tableCell =
        \maybeAlignment ->
            let
                attrs =
                    maybeAlignment
                        |> Maybe.map
                            (\alignment ->
                                case alignment of
                                    Block.AlignLeft ->
                                        "left"

                                    Block.AlignCenter ->
                                        "center"

                                    Block.AlignRight ->
                                        "right"
                            )
                        |> Maybe.map Attr.align
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
            in
            Html.td attrs
    }


heading : { level : Block.HeadingLevel, rawText : String, children : List (Html.Html msg) } -> Html.Html msg
heading { level, rawText, children } =
    case level of
        Block.H1 ->
            Typography.h1 [ class "pt-5 pb-2" ] children

        Block.H2 ->
            Typography.h2 [ class "pt-5 pb-2" ] children

        Block.H3 ->
            Typography.h3 [ class "pt-5 pb-2" ] children

        Block.H4 ->
            Typography.h4 [ class "pt-5 pb-2" ] children

        Block.H5 ->
            Typography.h5 [ class "pt-5 pb-2" ] children

        Block.H6 ->
            Typography.h6 [ class "pt-5 pb-2" ] children


codeBlock : { body : String, language : Maybe String } -> Html.Html msg
codeBlock details =
    let
        syntaxHighlight =
            case details.language of
                Just "elm" ->
                    SyntaxHighlight.elm

                Just "nix" ->
                    SyntaxHighlight.nix

                _ ->
                    SyntaxHighlight.noLang
    in
    Html.div
        [ class "pb-4" ]
        [ Html.node "style" [] [ Html.text theme ]
        , details.body
            |> String.trim
            |> syntaxHighlight
            |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
            |> Result.withDefault (Html.pre [] [ Html.code [] [ Html.text details.body ] ])
        ]


theme : String
theme =
    """
.elmsh {
    color: #f8f8f2;
    background: #282a36;
}

.elmsh-hl {
    background: #343434;
}

.elmsh-add {
    background: #003800;
}

.elmsh-del {
    background: #380000;
}

.elmsh-comm {
    color: #75715e;
}

.elmsh1 {
    color: #ae81ff;
}

.elmsh2 {
    color: #e6db74;
}

.elmsh3 {
    color: #f92672;
}

.elmsh4 {
    color: #66d9ef;
}

.elmsh5 {
    color: #a6e22e;
}

.elmsh6 {
    color: #ae81ff;
}

.elmsh7 {
    color: #fd971f;
}

.elmsh-elm-ts,
.elmsh-js-dk,
.elmsh-css-p {
    font-style: italic;
    color: #66d9ef;
}

.elmsh-js-ce {
    font-style: italic;
    color: #a6e22e;
}

.elmsh-css-ar-i {
    font-weight: bold;
    color: #f92672;
}
    """
        |> String.filter (not << (==) '\n')
        |> String.filter (not << (==) ' ')
