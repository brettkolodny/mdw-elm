module EnkryptBanner exposing (..)

import Html exposing (Html, div, node, text)
import Html.Attributes exposing (attribute, class)
import Model exposing (Model)
import Msg exposing (Msg)


enkryptBanner : Model -> Html Msg
enkryptBanner model =
    if model.extension.currentExtension /= Just "enkrypt" then
        div [ class "flex flex-col justify-center items-start gap-2 w-full max-w-4xl p-4 bg-[#9452fa] rounded-xl" ]
            [ div [ class "text-2xl text-white font-bold" ] [ text "Enkrypt: multi-chain web3 extension." ]
            , div [ class "max-w-xl text-left text-gray-100 text-sm" ] [ text "Enkrypt is a wallet extension that allows you to use all networks. Most popular ones, like Ethereum and Polkadot with its Parachains are already built in." ]
            , node "download-link" [ attribute "class" "bg-[#E6007A] text-white font-bold rounded-full px-4 py-3 cursor-pointer" ] []
            ]

    else
        div [] []
