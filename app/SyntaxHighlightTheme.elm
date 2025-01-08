module SyntaxHighlightTheme exposing (theme)


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
