module Article exposing (ArticleMetadata, articles, blogPosts, frontmatterDecoder)

import BackendTask exposing (BackendTask)
import BackendTask.File as File
import BackendTask.Glob as Glob
import Date exposing (Date)
import FatalError exposing (FatalError)
import Json.Decode as Decode exposing (Decoder)
import Route exposing (Route)


type alias BlogPost =
    { filePath : String
    , slug : String
    }


type alias ArticleMetadata =
    { title : String
    , description : String
    , published : Date
    }


articles : BackendTask FatalError (List ( Route, ArticleMetadata ))
articles =
    blogPosts
        |> BackendTask.map
            (\posts ->
                posts
                    |> List.map
                        (\{ filePath, slug } ->
                            BackendTask.map2 Tuple.pair
                                (BackendTask.succeed <| Route.Blog__Slug_ { slug = slug })
                                (File.onlyFrontmatter frontmatterDecoder filePath)
                        )
                    |> List.map BackendTask.allowFatal
            )
        |> BackendTask.resolve


blogPosts : BackendTask FatalError (List BlogPost)
blogPosts =
    Glob.succeed BlogPost
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


frontmatterDecoder : Decoder ArticleMetadata
frontmatterDecoder =
    Decode.map3 ArticleMetadata
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "published" decodePublished)


decodePublished : Decoder Date
decodePublished =
    Decode.string
        |> Decode.andThen
            (\stringDate ->
                case Date.fromIsoString stringDate of
                    Ok date ->
                        Decode.succeed date

                    Err msg ->
                        Decode.fail ("Invalid date: " ++ msg)
            )
