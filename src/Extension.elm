module Extension exposing (..)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))
import Session.Model exposing (Model)
import Session.Update as Session
import VitePluginHelper


selectExtension : Model -> Html Msg
selectExtension model =
    let
        currentExtension =
            extensionItem (Maybe.withDefault "connect" model.extension.currentExtension)
    in
    div [ class "flex" ]
        [ div
            [ class "relative flex flex-row justify-start items-center gap-2 border w-44 p-2 rounded-full text-sm font-bold cursor-pointer"
            , onClick (SessionMsg Session.ToggleShowExtensions)
            ]
            [ div [] [ currentExtension ] ]
        , if model.extension.showExtensions then
            div [ class "absolute flex flex-col divide-y w-44 bg-white border rounded-[26px] shadow-lg" ]
                (model.extension.extensions |> List.map (\e -> div [ class "py-2"] [ extensionItem e ]))

          else
            div [] []
        ]


extensionItem : String -> Html Msg
extensionItem extensionName =
    let
        ( name, image ) =
            case extensionName of
                "enkrypt" ->
                    ( "Enkrypt", img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/enkrypt.png" ] [] )

                "polkadot-js" ->
                    ( "Polkadot.js", img [ class "w-6 h-6", src <| VitePluginHelper.asset "/src/assets/polkadot-js.svg" ] [] )

                "connect" ->
                    ( "Connect", div [] [] )

                _ ->
                    ( extensionName, div [] [] )
    in
    div
        [ onClick (SessionMsg (Session.ConnectExtension extensionName))
        , class "flex flex-rowjustify-start items-center gap-2 w-44 pl-4 text-sm font-bold cursor-pointer"
        ]
        [ image, text name ]
