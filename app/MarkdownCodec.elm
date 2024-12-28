module MarkdownCodec exposing (withFrontmatter, withoutFrontmatter)

import BackendTask exposing (BackendTask)
import BackendTask.File as StaticFile
import FatalError exposing (FatalError)
import Json.Decode exposing (Decoder)
import Markdown.Block exposing (Block)
import Markdown.Parser
import Markdown.Renderer


withoutFrontmatter :
    Markdown.Renderer.Renderer view
    -> String
    -> BackendTask FatalError (List Block)
withoutFrontmatter renderer filePath =
    (filePath
        |> StaticFile.bodyWithoutFrontmatter
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\rawBody ->
                rawBody
                    |> Markdown.Parser.parse
                    |> Result.mapError (\_ -> FatalError.fromString "Couldn't parse markdown.")
                    |> BackendTask.fromResult
            )
    )
        |> BackendTask.andThen
            (\blocks ->
                blocks
                    |> Markdown.Renderer.render renderer
                    -- we don't want to encode the HTML since it contains functions so it's not serializable
                    -- but we can at least make sure there are no errors turning it into HTML before encoding it
                    |> Result.map (\_ -> blocks)
                    |> Result.mapError (\error -> FatalError.fromString error)
                    |> BackendTask.fromResult
            )


withFrontmatter :
    (frontmatter -> List Block -> value)
    -> Decoder frontmatter
    -> Markdown.Renderer.Renderer view
    -> String
    -> BackendTask FatalError value
withFrontmatter constructor frontmatterDecoder_ renderer filePath =
    BackendTask.map2 constructor
        (StaticFile.onlyFrontmatter
            frontmatterDecoder_
            filePath
            |> BackendTask.allowFatal
        )
        (StaticFile.bodyWithoutFrontmatter
            filePath
            |> BackendTask.allowFatal
            |> BackendTask.andThen
                (\rawBody ->
                    rawBody
                        |> Markdown.Parser.parse
                        |> Result.mapError (\_ -> FatalError.fromString "Couldn't parse markdown.")
                        |> BackendTask.fromResult
                )
            |> BackendTask.andThen
                (\blocks ->
                    blocks
                        |> Markdown.Renderer.render renderer
                        -- we don't want to encode the HTML since it contains functions so it's not serializable
                        -- but we can at least make sure there are no errors turning it into HTML before encoding it
                        |> Result.map (\_ -> blocks)
                        |> Result.mapError (\error -> FatalError.fromString error)
                        |> BackendTask.fromResult
                )
        )