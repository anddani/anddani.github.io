port module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Events
import Bytes exposing (Bytes)
import File exposing (File)
import File.Select
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import NES exposing (Button(..), ControllerNumber(..), NES)
import Task
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- PORTS


{-| For performance reasons we pass the framebuffer to JavaScript
and have it render it.
-}
port renderFramebuffer : Array (Array Int) -> Cmd msg



-- MODEL


type Status
    = Idle
    | Loaded NES
    | Error String


type alias Model =
    { status : Status
    , running : Bool
    , frameTimes : List Int -- millis of the last N frames (newest first)
    , nextFrameDueMs : Float -- rAF ticks earlier than this run no NES frame
    }


{-| NTSC NES frame period: 1000 / 60.0988 fps. requestAnimationFrame triggers
at the display's refresh rate, so cap it to avoid gameplay speed mismatch.
-}
framePeriodMs : Float
framePeriodMs =
    1000 / 60.0988


init : () -> ( Model, Cmd Msg )
init () =
    ( { status = Idle, running = True, frameTimes = [], nextFrameDueMs = 0 }, Cmd.none )



-- UPDATE


type Msg
    = PickRom
    | GotRomFile File
    | GotRomBytes Bytes
    | Tick Time.Posix
    | TogglePause
    | StepFrame
    | KeyDown String
    | KeyUp String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PickRom ->
            ( model
            , File.Select.file [ ".nes" ] GotRomFile
            )

        GotRomFile file ->
            ( model
            , Task.perform GotRomBytes (File.toBytes file)
            )

        GotRomBytes bytes ->
            case NES.fromRom bytes of
                Ok nes ->
                    ( { model | status = Loaded nes }, Cmd.none )

                Err _ ->
                    ( { model | status = Error "Failed to parse iNES bytes" }
                    , Cmd.none
                    )

        Tick now ->
            case model.status of
                Loaded nes ->
                    let
                        nowMs =
                            toFloat (Time.posixToMillis now)
                    in
                    if nowMs < model.nextFrameDueMs then
                        -- Too early (e.g. 120Hz display) — skip this rAF tick.
                        ( model, Cmd.none )

                    else
                        let
                            -- Schedule from the previous due time so timing
                            -- errors don't accumulate.
                            newDue =
                                if nowMs - model.nextFrameDueMs > 100 then
                                    nowMs + framePeriodMs

                                else
                                    model.nextFrameDueMs + framePeriodMs

                            nextNes =
                                stepUntilNextFrame nes

                            newFrameTimes =
                                List.take 60 (round nowMs :: model.frameTimes)
                        in
                        ( { model
                            | status = Loaded nextNes
                            , frameTimes = newFrameTimes
                            , nextFrameDueMs = newDue
                          }
                        , renderFramebuffer (NES.framebuffer nextNes)
                        )

                _ ->
                    ( model, Cmd.none )

        TogglePause ->
            ( { model | running = not model.running }, Cmd.none )

        StepFrame ->
            case model.status of
                Loaded nes ->
                    let
                        nextNes =
                            stepUntilNextFrame nes
                    in
                    ( { model | status = Loaded nextNes }
                    , renderFramebuffer (NES.framebuffer nextNes)
                    )

                _ ->
                    ( model, Cmd.none )

        KeyDown key ->
            ( applyKey True key model, Cmd.none )

        KeyUp key ->
            ( applyKey False key model, Cmd.none )



-- HELPERS


{-| Run NES.step until the PPU's frame counter advances by 1.
-}
stepUntilNextFrame : NES -> NES
stepUntilNextFrame initialNes =
    let
        startFrame =
            NES.frameCount initialNes

        go : NES -> NES
        go nes =
            if NES.frameCount nes > startFrame then
                nes

            else
                go (Tuple.first (NES.step nes))
    in
    go initialNes


{-| Map a browser KeyboardEvent.key value to a NES controller button.
-}
keyToButton : String -> Maybe Button
keyToButton key =
    case key of
        "z" ->
            Just A

        "Z" ->
            Just A

        "x" ->
            Just B

        "X" ->
            Just B

        "Shift" ->
            Just Select

        "Enter" ->
            Just Start

        "ArrowUp" ->
            Just Up

        "ArrowDown" ->
            Just Down

        "ArrowLeft" ->
            Just Left

        "ArrowRight" ->
            Just Right

        _ ->
            Nothing


{-| Apply a key press/release to the first controller of the loaded NES.
No-op if no ROM is loaded or the key isn't mapped to a button.
-}
applyKey : Bool -> String -> Model -> Model
applyKey pressed key model =
    case ( model.status, keyToButton key ) of
        ( Loaded nes, Just button ) ->
            { model | status = Loaded (NES.signalControllerButton Controller1 button pressed nes) }

        _ ->
            model



-- VIEW


buttonClass : Html.Attribute Msg
buttonClass =
    class "cursor-pointer border-2 border-b-gray-600 border-l-gray-300 border-r-gray-600 border-t-gray-300 bg-stone-50 px-3 py-1 text-sm font-mincho active:border-b-gray-300 active:border-l-gray-600 active:border-r-gray-300 active:border-t-gray-600 dark:bg-stone-800"


view : Model -> Html Msg
view model =
    div [ class "flex flex-col gap-3" ]
        [ div [ class "flex gap-3" ]
            [ button [ buttonClass, onClick PickRom ] [ text "Load ROM" ]
            , button [ buttonClass, onClick TogglePause ]
                [ text
                    (if model.running then
                        "Pause"

                     else
                        "Resume"
                    )
                ]
            , button [ buttonClass, onClick StepFrame ] [ text "Step Frame" ]
            ]
        , viewStatus model
        ]


viewStatus : Model -> Html Msg
viewStatus model =
    div [ class "text-sm text-stone-500 dark:text-stone-400" ]
        [ case model.status of
            Idle ->
                p [] [ text "No ROM loaded" ]

            Loaded nes ->
                viewInfo nes (computeFps model.frameTimes)

            Error err ->
                p [] [ text ("Error: " ++ err) ]
        ]


computeFps : List Int -> Maybe Float
computeFps times =
    case ( List.head times, times |> List.reverse |> List.head ) of
        ( Just newest, Just oldest ) ->
            let
                count =
                    List.length times

                spanMs =
                    newest - oldest
            in
            if spanMs > 0 && count > 1 then
                Just (toFloat (count - 1) * 1000.0 / toFloat spanMs)

            else
                Nothing

        _ ->
            Nothing


viewInfo : NES -> Maybe Float -> Html Msg
viewInfo nes fps =
    p [ class "font-mono text-xs" ]
        [ text
            ("FPS: "
                ++ (case fps of
                        Just f ->
                            String.fromInt (round f)

                        Nothing ->
                            "—"
                   )
            )
        , text (" | Frame " ++ String.fromInt (NES.frameCount nes))
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        -- Drop key-repeat events. Holding a key spams keydown ~30/sec; each
        -- one runs update + a re-render, which tanks framerate.
        keyDecoder : (String -> Msg) -> Decode.Decoder Msg
        keyDecoder toMsg =
            Decode.field "repeat" Decode.bool
                |> Decode.andThen
                    (\isRepeat ->
                        if isRepeat then
                            Decode.fail "ignore key repeat"

                        else
                            Decode.field "key" Decode.string |> Decode.map toMsg
                    )

        keyboard =
            [ Browser.Events.onKeyDown (keyDecoder KeyDown)
            , Browser.Events.onKeyUp (keyDecoder KeyUp)
            ]

        clock =
            case ( model.status, model.running ) of
                ( Loaded _, True ) ->
                    [ Browser.Events.onAnimationFrame Tick ]

                _ ->
                    []
    in
    Sub.batch (keyboard ++ clock)
