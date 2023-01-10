module Success exposing (..)

import Html exposing (Html, a, div, h1, img, text)
import Html.Attributes exposing (class, href, src)
import VitePluginHelper


success : String -> Html msg
success path =
    div [ class "w-full flex flex-col justify-center items-center mt-12 gap-4" ]
        [ div
            [ class "flex flex-col justify-center items-center gap-4 w-full max-w-4xl bg-white p-4 py-8 rounded-xl shadow-lg" ]
            [ img [ src <| VitePluginHelper.asset "/src/assets/icons/success.svg" ] []
            , h1 [ class "text-2xl font-semibold" ] [ text "Your transaction was successful!" ]
            , a
                [ href path
                , class "flex justify-center items-center w-48 h-12 text-lg font-medium bg-[#e6007a] text-white rounded-full"
                ]
                [ text "Send another" ]
            ]
        ]
