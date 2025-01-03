module Api exposing (manifest, routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Pages.Manifest as Manifest
import Route exposing (Route)


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes _ _ =
    []


manifest : Manifest.Config
manifest =
    Manifest.init
        { name = "André Danielsson"
        , description = "Personal website"
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }
