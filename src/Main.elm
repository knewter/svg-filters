module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html.App exposing (program)
import Animation exposing (px)


type alias Model =
    { x : Animation.State
    }


type Msg
    = Animate Animation.Msg


main : Program Never
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animMsg ->
            ( { model
                | x = Animation.update animMsg model.x
              }
            , Cmd.none
            )


init : ( Model, Cmd Msg )
init =
    ( { x =
            Animation.style
                [ Animation.translate3d (px 0) (px 0) (px 0)
                , Animation.rotate <| Animation.deg 15
                ]
      }
        |> beginSliding
    , Cmd.none
    )


factor =
    30


beginSliding : Model -> Model
beginSliding model =
    let
        x =
            Animation.interrupt
                [ Animation.loop
                    [ Animation.toWith
                        (Animation.speed { perSecond = 1 * factor })
                        [ Animation.translate3d (px 300) (px 0) (px 0)
                        ]
                    , Animation.toWith
                        (Animation.speed { perSecond = 1 * factor })
                        [ Animation.translate3d (px 0) (px 0) (px 0)
                        ]
                    ]
                ]
                model.x
    in
        { model | x = x }


view : Model -> Svg msg
view model =
    svg
        [ version "1.1"
        , x "0"
        , y "0"
        , viewBox "0 0 323.141 322.95"
        ]
        [ defs []
            [ Svg.filter [ id "blur" ]
                [ feGaussianBlur [ stdDeviation "2,0" ] []
                , feColorMatrix [ in' "BackgroundImage", type' "saturate", values "2.0" ] []
                ]
            , Svg.clipPath [ id "moving-rect" ]
                [ rect
                    ((Animation.render model.x)
                        ++ [ x "0", y "0", width "50", height "100%" ]
                    )
                    []
                ]
            ]
        , image
            [ xlinkHref "https://static.pexels.com/photos/174/coffee-apple-iphone-laptop.jpg"
            , height "100%"
            , width "100%"
            , Svg.Attributes.style "position: absolute; top: 0; left: 0;"
            ]
            []
        , image
            [ xlinkHref "https://static.pexels.com/photos/174/coffee-apple-iphone-laptop.jpg"
            , height "100%"
            , width "100%"
            , Svg.Attributes.style "position: absolute; top: 0; left: 0;"
            , Svg.Attributes.filter "url(#blur)"
            , Svg.Attributes.clipPath "url(#moving-rect)"
            ]
            []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription Animate [ model.x ]
        ]
