port module Main exposing (main)

import Accounts exposing (accounts)
import Browser
import Extension exposing (selectExtension)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (Decoder, field, float, map, map2)
import Model exposing (Account, Model, Network(..), Prices, Route(..), Usd)
import Msg exposing (Msg(..))
import NavBar exposing (navBar)
import Network exposing (networkSelect)


main : Program (List String) Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- PORTS


port updateAccounts : (List Account -> msg) -> Sub msg


type alias PortData =
    { network : Maybe String, extension : Maybe String }


type alias PortMessage =
    { tag : String
    , data : PortData
    }


port sendMessage : PortMessage -> Cmd msg


init : List String -> ( Model, Cmd Msg )
init extensions =
    ( { accounts = []
      , count = 0
      , network = { currentNetwork = Polkadot, showNetworks = False }
      , prices = Nothing
      , extension =
            { extensions = extensions
            , currentExtension = Nothing
            , showExtensions = False
            }
      , route = AccountsRoute
      }
    , Http.get
        { url = "https://api.coingecko.com/api/v3/simple/price?ids=polkadot%2Ckusama&vs_currencies=usd"
        , expect = Http.expectJson GotPrices pricesDecoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAccounts accounts ->
            ( { model | accounts = accounts }, Cmd.none )

        ToggleAccountInfo address ->
            ( { model | accounts = List.map (toggleAccount address) model.accounts }, Cmd.none )

        ToggleShowNetworks ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | showNetworks = not oldNetwork.showNetworks }
            in
            ( { model | network = newNetwork }, Cmd.none )

        SwitchNetwork network ->
            let
                oldNetwork =
                    model.network

                newNetwork =
                    { oldNetwork | currentNetwork = network, showNetworks = not oldNetwork.showNetworks }

                networkString =
                    case network of
                        Polkadot ->
                            "Polkadot"

                        Kusama ->
                            "Kusama"

                accounts =
                    List.map (\account -> { account | balance = Nothing }) model.accounts
            in
            ( { model | network = newNetwork, accounts = accounts }
            , sendMessage
                { tag = "network-update"
                , data = { network = Just networkString, extension = model.extension.currentExtension }
                }
            )

        ConnectExtension extensionName ->
            let
                oldExtensionState =
                    model.extension

                netExtensionState =
                    { oldExtensionState | currentExtension = Just extensionName, showExtensions = False }
            in
            if extensionName /= Maybe.withDefault "" model.extension.currentExtension then
                ( { model | extension = netExtensionState }
                , sendMessage { tag = "extension-connect", data = { network = Nothing, extension = Just extensionName } }
                )

            else
                ( model, Cmd.none )

        GotPrices result ->
            case result of
                Ok prices ->
                    ( { model | prices = Just prices }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ToggleShowExtensions ->
            let
                oldExtensionState =
                    model.extension

                newExtensionState =
                    { oldExtensionState | showExtensions = not oldExtensionState.showExtensions }
            in
            ( { model | extension = newExtensionState }, Cmd.none )


toggleAccount : String -> Account -> Account
toggleAccount address account =
    if address == account.address then
        { account | show = not account.show }

    else
        account


view : Model -> Html Msg
view model =
    let
        page =
            case model.route of
                AccountsRoute ->
                    accounts

                SendRoute s ->
                    accounts

                NotFoundRoute ->
                    accounts
    in
    div [ class "flex flex-col justify-center items-center" ]
        [ div [ class "absolute flex flex-row justify-center items-center h-20 w-screen top-0 left-0 " ]
            [ div [ class "flex flex-row justify-end w-full max-w-5xl gap-24 mt-4" ]
                [ networkSelect model.network
                , selectExtension model
                ]
            ]
        , div [ class "flex flex-row w-full" ] [ navBar model, page model ]
        ]


pricesDecoder : Decoder Prices
pricesDecoder =
    let
        decodeUsd =
            map Usd (field "usd" float)
    in
    map2 Prices
        (field "polkadot" decodeUsd)
        (field "kusama" decodeUsd)


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateAccounts UpdateAccounts
