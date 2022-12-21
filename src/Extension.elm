module Extension exposing (..)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Session.Model exposing (Model)
import Msg exposing (Msg(..))
import VitePluginHelper


selectExtension : Model -> Html Msg
selectExtension model =
    let
        currentExtension =
            extensionItem (Maybe.withDefault "connect" model.extension.currentExtension)
    in
    div [class "flex justify-start items-center py-2 border rounded-full"]
        [ div [ class "flex flex-col justify-start items-center pl-4 text-lg font-bold" ]
            [ div [ onClick ToggleShowExtensions ] [ currentExtension ]
            , div
                []
                (if model.extension.showExtensions then
                    model.extension.extensions
                        |> List.filter (\a -> a /= Maybe.withDefault "" model.extension.currentExtension)
                        |> List.map extensionItem

                 else
                    []
                )
            ]
        ]


extensionItem : String -> Html Msg
extensionItem extensionName =
    let
        ( name, image ) =
            case extensionName of
                "enkrypt" ->
                    ( "Enkrypt", img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/enkrypt.png" ] [] )

                "polkadot-js" ->
                    ( "Polkadot-js", img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/polkadot-js.svg" ] [] )

                "connect" ->
                    ( "Connect", div [] [] )

                _ ->
                    ( extensionName, div [] [] )
    in
    div
        [ onClick (ConnectExtension extensionName)
        , class "flex flex-row justify-start items-center gap-2 w-40 cursor-pointer"
        ]
        [ image, text name ]


formatExtensionName : String -> String
formatExtensionName extensionName =
    case extensionName of
        "enkrypt" ->
            "Enkrypt"

        "polkadot-js" ->
            "Polkadot.js"

        _ ->
            extensionName
